# syntax=docker/dockerfile:1.7

FROM node:20.20.2-bookworm AS dependencies

WORKDIR /opt/plantini
COPY package.json package-lock.json ./
# Strapi's upload plugin loads Sharp at startup, so lifecycle scripts must run
# here to install the architecture-specific prebuilt binary into the image.
RUN npm ci

FROM dependencies AS build

COPY . ./
ENV NODE_ENV=production
RUN npm run lint && npm run check && npm test && npm run build

FROM node:20.20.2-bookworm-slim AS runtime

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=1337 \
    PRIVATE_UPLOAD_DIR=/var/lib/plantini/private-media

RUN groupadd --system --gid 10001 plantini \
    && useradd --system --uid 10001 --gid plantini --home-dir /opt/plantini plantini \
    && mkdir -p /opt/plantini/public/uploads /var/lib/plantini/private-media \
    && chown -R plantini:plantini /var/lib/plantini /opt/plantini

WORKDIR /opt/plantini
COPY --chown=plantini:plantini --from=build /opt/plantini ./

USER plantini
EXPOSE 1337

CMD ["npm", "run", "start"]
