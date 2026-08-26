FROM node:20.20.2-alpine

WORKDIR /srv/plantnet-mock
COPY server.mjs ./

USER node
EXPOSE 1080

CMD ["node", "server.mjs"]
