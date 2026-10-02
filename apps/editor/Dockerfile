FROM nginxinc/nginx-unprivileged:1.27.4-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html app.js json-editor.js style.css /usr/share/nginx/html/
EXPOSE 8080
