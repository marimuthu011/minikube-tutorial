## npm run build --prod
## podman build -f Dockerfile -t quay.io/zagaos/observai-dashboard .
## podman run -i --rm -p 8080:8080 quay.io/zagaos/observai-dashboard

FROM docker.io/nginxinc/nginx-unprivileged

USER root

COPY ../dist /usr/share/nginx/html

COPY ./sample/nginx.conf /etc/nginx/conf.d/default.conf

RUN     chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx/conf.d

RUN     touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid
USER nginx

EXPOSE 8080

CMD ["nginx","-g","daemon off;"]
