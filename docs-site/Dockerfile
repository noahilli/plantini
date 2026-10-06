# Handbuch bauen und statisch ausliefern.
# Build-Kontext ist das Repo-Wurzelverzeichnis (der Hook generate_reference.py liest Vertrag, Compose-Dateien
# und Quelltext); Dockerfile.dockerignore beschränkt den Kontext auf genau diese Eingaben.
#   docker build -f docs-site/Dockerfile -t plantini-docs .
# Zugang: Basic Auth gegen /etc/nginx/htpasswd/docs.htpasswd (wird beim Start eingehängt, nicht im Image).
FROM python:3.12-slim AS build
WORKDIR /repo/docs-site
COPY docs-site/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY contracts/api.yaml /repo/contracts/api.yaml
COPY infra/compose*.yaml infra/production.env.example /repo/infra/
COPY infra/production/Caddyfile /repo/infra/production/Caddyfile
COPY services/platform/src /repo/services/platform/src
COPY services/platform/config /repo/services/platform/config
COPY apps/flutter/lib /repo/apps/flutter/lib
COPY docs-site /repo/docs-site
RUN mkdocs build --strict

FROM nginxinc/nginx-unprivileged:1.27.4-alpine
COPY docs-site/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /repo/docs-site/site /usr/share/nginx/html
EXPOSE 8080
