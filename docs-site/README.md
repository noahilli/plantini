# Plantini Handbuch (MkDocs)

Quelltext des Handbuchs für Mitwirkende, Betrieb und Moderation. Deutsch, Theme „Plantini“ (MkDocs Material mit `overrides/` und `docs/assets/stylesheets/plantini.css`), alle Schriften und Skripte lokal eingebunden.

```sh
cd docs-site
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/mkdocs serve            # http://127.0.0.1:8000
.venv/bin/mkdocs build --strict   # Ausgabe in site/ (ignoriert)
```

- `hooks/generate_reference.py` erzeugt aus dem Repo drei Seiten: API-Referenz (`contracts/api.yaml`), Konfiguration (`infra/*.env.example`/Compose) und Ports/Dienste. Sie müssen nicht von Hand gepflegt werden.
- `scripts/capture-*.cjs` nehmen Screenshots und Animationsbilder gegen einen lokalen Stack mit **synthetischen** Konten auf, `scripts/make_gif.py` baut daraus GIFs. Nie gegen Produktion laufen lassen.
- Container (nicht ausgerollt, Build getestet; Port 8080 im Container). Vom Repo-Wurzelverzeichnis, mit BuildKit (`docker buildx`):

  ```sh
  docker build -f docs-site/Dockerfile -t plantini-docs .
  ```

  Mit dem alten Builder (ohne buildx) wird `Dockerfile.dockerignore` nicht beachtet und der ganze Baum eingelesen. Dann den Kontext selbst schmal halten:

  ```sh
  tar --exclude=docs-site/.venv --exclude=docs-site/site --exclude=__pycache__ -cf - \
    contracts/api.yaml infra/compose*.yaml infra/production.env.example infra/production/Caddyfile \
    services/platform/src services/platform/config apps/flutter/lib docs-site \
    | docker build -f docs-site/Dockerfile -t plantini-docs -
  ```
