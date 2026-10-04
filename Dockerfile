FROM eceasy/cli-proxy-api:latest

WORKDIR /CLIProxyAPI

COPY entrypoint.sh /entrypoint.sh
COPY config.template.yaml /CLIProxyAPI/config.template.yaml

RUN chmod +x /entrypoint.sh && mkdir -p /data

ENV PORT=8317
ENV TZ=Asia/Dhaka
ENV HOME=/data

EXPOSE 8317

ENTRYPOINT ["/entrypoint.sh"]
