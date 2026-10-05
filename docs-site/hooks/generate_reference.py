"""Generates the reference pages that drift fastest from the repository itself.

* backend/api-referenz.md  <- contracts/api.yaml (every operation and schema)
* betrieb/konfiguration.md <- infra/production.env.example, process.env in the platform,
                              String.fromEnvironment in the app
* referenz/ports-dienste.md <- infra/compose.production.yaml, infra/compose.e2e.yaml,
                              infra/production/Caddyfile

Nothing here is hand-written text about values: a changed contract or compose file
changes the handbook on the next build.
"""
from __future__ import annotations

import re
from pathlib import Path

import yaml
from mkdocs.structure.files import File

ROOT = Path(__file__).resolve().parents[2]
SECRET_HINT = re.compile(r"(PASSWORD|SECRET|_KEY|SALT|TOKEN|KEYS)$")


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


# ---------------------------------------------------------------- API reference
def schema_type(schema: dict | None) -> str:
    if not schema:
        return "–"
    if "$ref" in schema:
        name = schema["$ref"].split("/")[-1]
        return f"[`{name}`](#schema-{name.lower()})"
    kind = schema.get("type", "object")
    if isinstance(kind, list):  # OpenAPI 3.1: ["string", "null"]
        kind = " | ".join(str(k) for k in kind)
    if "allOf" in schema or "oneOf" in schema or "anyOf" in schema:
        parts = schema.get("allOf") or schema.get("oneOf") or schema.get("anyOf")
        return " / ".join(schema_type(p) for p in parts)
    if kind == "array":
        return f"{schema_type(schema.get('items'))}[]"
    if "enum" in schema:
        return f"{kind} ∈ {{{', '.join(f'`{v}`' for v in schema['enum'])}}}"
    extra = []
    for key in ("format", "minimum", "maximum", "maxLength", "minLength", "pattern"):
        if key in schema:
            extra.append(f"{key}={schema[key]}")
    return kind + (f" ({', '.join(extra)})" if extra else "")


def esc(text: str | None) -> str:
    return (text or "").replace("|", "\\|").replace("\n", " ").strip()


def api_page() -> str:
    spec = yaml.safe_load((ROOT / "contracts/api.yaml").read_text(encoding="utf-8"))
    out = [
        "# API-Referenz",
        "",
        f"Diese Seite wird beim Bauen aus `contracts/api.yaml` erzeugt (**{spec['info']['title']}**, Version `{spec['info']['version']}`). "
        "Sie ist vollständig und wird nie von Hand gepflegt: Änderungen gehören in den Vertrag (siehe [API-Vertrag](api-vertrag.md)).",
        "",
        f"Basis-URL in der Entwicklung: `{spec['servers'][0]['url']}`. Alle Operationen verlangen ein Bearer-Token, "
        "außer wenn „öffentlich“ angegeben ist.",
        "",
    ]
    conv = spec.get("x-plantini-api-conventions", {})
    if conv:
        out += ["## Konventionen", "", "| Schlüssel | Wert |", "|---|---|"]
        out += [f"| `{k}` | {esc(str(v))} |" for k, v in conv.items()]
        out.append("")
    tags = {t["name"]: t.get("description", "") for t in spec.get("tags", [])}
    by_tag: dict[str, list[tuple[str, str, dict]]] = {}
    for path, item in spec["paths"].items():
        for method, op in item.items():
            if method not in {"get", "post", "put", "patch", "delete"}:
                continue
            by_tag.setdefault((op.get("tags") or ["Sonstige"])[0], []).append((method.upper(), path, op))
    total = sum(len(v) for v in by_tag.values())
    out += [f"## Operationen ({total})", ""]
    for tag in sorted(by_tag, key=lambda t: list(tags).index(t) if t in tags else 99):
        out += [f"### {tag}", ""]
        if tags.get(tag):
            out += [esc(tags[tag]), ""]
        for method, path, op in sorted(by_tag[tag], key=lambda x: (x[1], x[0])):
            public = op.get("security") == []
            out += [f"#### `{method} {path}` {{#{op['operationId'].lower()}}}", ""]
            out += [f"**{esc(op.get('summary'))}** · `{op['operationId']}` · {'öffentlich' if public else 'Bearer-Token'}", ""]
            if op.get("description"):
                out += [esc(op["description"]), ""]
            params = list(spec["paths"][path].get("parameters", [])) + list(op.get("parameters", []))
            rows = []
            for p in params:
                if "$ref" in p:
                    p = spec["components"]["parameters"][p["$ref"].split("/")[-1]]
                rows.append(f"| `{p['name']}` | {p['in']} | {'ja' if p.get('required') else 'nein'} | "
                            f"{schema_type(p.get('schema'))} | {esc(p.get('description'))} |")
            if rows:
                out += ["| Parameter | in | Pflicht | Typ | Beschreibung |", "|---|---|---|---|---|", *rows, ""]
            body = op.get("requestBody")
            if body:
                content = body.get("content", {})
                for media, desc in content.items():
                    out += [f"Request-Body (`{media}`, {'Pflicht' if body.get('required') else 'optional'}): "
                            f"{schema_type(desc.get('schema'))}", ""]
            resp_rows = []
            for code, resp in op.get("responses", {}).items():
                if "$ref" in resp:
                    resp = spec["components"]["responses"][resp["$ref"].split("/")[-1]]
                media = next(iter(resp.get("content", {}).items()), (None, {}))
                kind = f"`{media[0]}` {schema_type(media[1].get('schema'))}" if media[0] else ""
                resp_rows.append(f"| {code} | {esc(resp.get('description'))} | {kind} |")
            out += ["| Status | Bedeutung | Antwort |", "|---|---|---|", *resp_rows, ""]
    out += ["## Schemas", ""]
    for name, schema in sorted(spec["components"]["schemas"].items()):
        out += [f"### {name} {{#schema-{name.lower()}}}", ""]
        if schema.get("description"):
            out += [esc(schema["description"]), ""]
        props = schema.get("properties")
        if props:
            required = set(schema.get("required", []))
            out += ["| Feld | Typ | Pflicht | Beschreibung |", "|---|---|---|---|"]
            out += [f"| `{k}` | {schema_type(v)} | {'ja' if k in required else 'nein'} | {esc(v.get('description') if isinstance(v, dict) else '')} |"
                    for k, v in props.items()]
            out.append("")
        elif "enum" in schema:
            out += [f"Aufzählung: {', '.join(f'`{v}`' for v in schema['enum'])}", ""]
        else:
            out += [f"Typ: {schema_type(schema)}", ""]
    return "\n".join(out)


# ---------------------------------------------------------------- configuration
def env_example_groups() -> list[tuple[str, list[tuple[str, str]]]]:
    groups, comments, current = [], [], []
    for line in (ROOT / "infra/production.env.example").read_text().splitlines():
        if not line.strip():
            if current:
                groups.append((" ".join(comments), current))
            comments, current = [], []
        elif line.startswith("#"):
            if current:
                groups.append((" ".join(comments), current))
                comments, current = [], []
            comments.append(line.lstrip("# ").strip())
        else:
            name, _, value = line.partition("=")
            current.append((name, value))
    if current:
        groups.append((" ".join(comments), current))
    return groups


def platform_env() -> list[tuple[str, str]]:
    found: dict[str, str] = {}
    for base in ("services/platform/src", "services/platform/config"):
        for path in sorted((ROOT / base).rglob("*.js")):
            for number, line in enumerate(path.read_text(errors="ignore").splitlines(), 1):
                for name in re.findall(r"process\.env\.([A-Z][A-Z0-9_]+)", line):
                    found.setdefault(name, f"{rel(path)}:{number}")
    return sorted(found.items())


def app_defines() -> list[tuple[str, str]]:
    found: dict[str, str] = {}
    for path in sorted((ROOT / "apps/flutter/lib").rglob("*.dart")):
        text = path.read_text(errors="ignore")
        for match in re.finditer(r"(?:String|bool|int)\.fromEnvironment\(\s*'([A-Z0-9_]+)'", text):
            line = text.count("\n", 0, match.start()) + 1
            found.setdefault(match.group(1), f"{rel(path)}:{line}")
    return sorted(found.items())


def config_page() -> str:
    out = [
        "# Konfiguration",
        "",
        "Alle Konfigurationswerte des Systems, **automatisch** aus dem Repository zusammengestellt. "
        "Werte der Produktion stehen nie im Repository: `production.env` liegt nur auf dem Server und wird "
        "über einen Geheimnisspeicher gepflegt.",
        "",
        "## Produktions-Umgebung (`infra/production.env.example`)",
        "",
    ]
    for comment, items in env_example_groups():
        if comment:
            out += [f"> {comment}", ""]
        out += ["| Variable | Beispielwert | Geheim |", "|---|---|---|"]
        for name, value in items:
            secret = bool(SECRET_HINT.search(name)) and "PUBLIC" not in name
            out.append(f"| `{name}` | {('`' + value + '`') if value and not secret else '–'} | {'ja' if secret else 'nein'} |")
        out.append("")
    out += [
        "## Variablen, die die Plattform zur Laufzeit liest",
        "",
        "Gefunden per `process.env.*` in `services/platform/src` und `services/platform/config` "
        "(erste Fundstelle). Welche davon `infra/compose.production.yaml` setzt, zeigt die Compose-Datei.",
        "",
        "| Variable | Erste Fundstelle |",
        "|---|---|",
        *[f"| `{n}` | `{w}` |" for n, w in platform_env()],
        "",
        "## Build-Konstanten der App (`--dart-define`)",
        "",
        "```sh\nflutter build web --release \\\n  --dart-define=PLANTINI_ENV=production \\\n"
        "  --dart-define=PLANTINI_API_BASE_URL=https://api.<domain>/api/v1 \\\n"
        "  --dart-define=PLANTINI_OIDC_ISSUER_URL=https://auth.<domain>/realms/plantini \\\n"
        "  --dart-define=PLANTINI_OIDC_CLIENT_ID=plantini-web-production\n```",
        "",
        "| Konstante | Fundstelle |",
        "|---|---|",
        *[f"| `{n}` | `{w}` |" for n, w in app_defines()],
        "",
    ]
    return "\n".join(out)


# ---------------------------------------------------------------- services & ports
def compose_services(path: Path) -> dict:
    return (yaml.safe_load(path.read_text()) or {}).get("services", {})


def compose_table(path: Path) -> list[str]:
    rows = ["| Dienst | Image | Host-Ports | Netze | Härtung | Health |", "|---|---|---|---|---|---|"]
    for name, svc in compose_services(path).items():
        image = svc.get("image") or ("build: " + str((svc.get("build") or {}).get("context", "?")) if svc.get("build") else "–")
        image = re.sub(r"\$\{([A-Z_]+):\?[^}]*\}", r"${\1}", str(image))
        ports = "<br>".join(f"`{p}`" for p in svc.get("ports", [])) or "–"
        nets = svc.get("networks")
        nets = ", ".join(nets if isinstance(nets, list) else list(nets or [])) or "–"
        hard = []
        if svc.get("read_only"):
            hard.append("read_only")
        if svc.get("cap_drop"):
            hard.append("cap_drop")
        if any("no-new-privileges" in str(o) for o in svc.get("security_opt", [])):
            hard.append("no-new-privileges")
        rows.append(f"| `{name}` | `{esc(str(image))}` | {ports} | {nets} | {', '.join(hard) or '–'} | "
                    f"{'ja' if svc.get('healthcheck') else 'nein'} |")
    return rows


def caddy_routes() -> list[str]:
    text = (ROOT / "infra/production/Caddyfile").read_text()
    rows = ["| Host | Ziel |", "|---|---|"]
    for block in re.finditer(r"^([a-z.{}$A-Z_]+)\s*\{\n(.*?)^\}", text, re.M | re.S):
        host, body = block.group(1), block.group(2)
        if host.startswith("(") or host == "":
            continue
        targets = re.findall(r"reverse_proxy\s+(\S+)", body)
        if targets:
            target = ", ".join(f"Proxy → `{t}`" for t in targets)
        elif "file_server" in body:
            target = "statische Dateien"
        elif "redir" in body:
            target = "Weiterleitung auf die Apex-Domain"
        else:
            target = "–"
        if "handle /download/*" in body:
            target += " (+ `/download/*` aus dem Downloads-Verzeichnis)"
        rows.append(f"| `{host.replace('{$PLANTINI_DOMAIN}', '<domain>')}` | {target} |")
    return rows


def ports_page() -> str:
    return "\n".join([
        "# Dienste und Ports",
        "",
        "Automatisch aus den Compose-Dateien und dem Caddyfile erzeugt. Alle Host-Ports sind an `127.0.0.1` "
        "gebunden; nach außen sind ausschließlich 80/443 von Caddy offen.",
        "",
        "## Öffentliche Hosts (`infra/production/Caddyfile`)",
        "",
        *caddy_routes(),
        "",
        "## Produktion (`infra/compose.production.yaml`)",
        "",
        *compose_table(ROOT / "infra/compose.production.yaml"),
        "",
        "## Lokaler E2E-Stack (`infra/compose.e2e.yaml`)",
        "",
        *compose_table(ROOT / "infra/compose.e2e.yaml"),
        "",
        "## Lokale Overlays",
        "",
        *[line for f in ("compose.editor.local.yaml", "compose.teacher.local.yaml", "compose.authoring.local.yaml", "compose.plantnet.local.yaml")
          for line in (f"### `infra/{f}`", "", *compose_table(ROOT / "infra" / f), "")],
    ])


GENERATED = {
    "backend/api-referenz.md": api_page,
    "betrieb/konfiguration.md": config_page,
    "referenz/ports-dienste.md": ports_page,
}


def on_files(files, config):
    for uri, build in GENERATED.items():
        existing = files.get_file_from_path(uri)
        if existing:
            files.remove(existing)
        files.append(File.generated(config, uri, content=build()))
    return files
