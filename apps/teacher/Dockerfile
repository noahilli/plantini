FROM nginxinc/nginx-unprivileged:1.27.4-alpine
USER root
RUN apk add --no-cache jq
COPY nginx.conf.template /opt/teacher/nginx.conf.template
COPY 40-teacher-config.sh /docker-entrypoint.d/40-teacher-config.sh
RUN chmod 755 /docker-entrypoint.d/40-teacher-config.sh
COPY index.html app.js style.css /usr/share/nginx/html/
USER nginx
ENV PLANTINI_API_BASE_URL=https://api.plantini.eu/api/v1 \
    PLANTINI_OIDC_ISSUER_URL=https://auth.plantini.eu/realms/plantini \
    PLANTINI_OIDC_CLIENT_ID=plantini-teacher-production \
    TEACHER_LISTEN_PORT=8080
EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.d/40-teacher-config.sh"]
CMD ["nginx", "-c", "/tmp/teacher-nginx.conf", "-g", "daemon off;"]
