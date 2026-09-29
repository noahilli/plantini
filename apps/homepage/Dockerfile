# syntax=docker/dockerfile:1.7
FROM node:20.20.2-bookworm-slim AS build
WORKDIR /site
COPY package.json package-lock.json ./
RUN npm ci
COPY . ./
ARG PLANTINI_APP_URL=https://app.plantini.eu
ENV PLANTINI_APP_URL=$PLANTINI_APP_URL
RUN npm run build

# Static server without root privileges; run with a read-only root filesystem
# and a tmpfs on /tmp.
FROM nginxinc/nginx-unprivileged:1.27.4-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY security-headers.conf /etc/nginx/plantini-headers.conf
COPY --from=build /site/dist /usr/share/nginx/html
EXPOSE 8080
