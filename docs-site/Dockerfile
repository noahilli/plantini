# Handbuch bauen und statisch ausliefern. Build-Kontext: docs-site/ (nicht das Repo-Wurzelverzeichnis,
# der Hook generate_reference.py liest ../contracts, ../infra und ../services; siehe README).
FROM python:3.12-slim AS build
WORKDIR /repo/docs-site
COPY docs-site/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY contracts /repo/contracts
COPY infra /repo/infra
COPY services /repo/services
COPY docs-site /repo/docs-site
RUN mkdocs build --strict

FROM nginxinc/nginx-unprivileged:1.27.4-alpine
COPY --from=build /repo/docs-site/site /usr/share/nginx/html
EXPOSE 8080
