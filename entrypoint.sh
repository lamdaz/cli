#!/bin/sh
set -eu

PORT="${PORT:-8317}"
TZ="${TZ:-Asia/Dhaka}"

export TZ
export HOME=/data

mkdir -p /data/auth
mkdir -p /data/logs
mkdir -p /data/plugins

# Persist CLIProxyAPI authentication
mkdir -p /root

if [ ! -e /root/.cli-proxy-api ]; then
    ln -s /data/auth /root/.cli-proxy-api
fi

# Create config on first boot
if [ ! -f /data/config.yaml ]; then
    cp /CLIProxyAPI/config.template.yaml /data/config.yaml
fi

# Keep Render's port
sed -i "s/^port: .*/port: ${PORT}/" /data/config.yaml

# Configure API key only if placeholder exists
if [ -n "${API_KEY:-}" ]; then
    ESCAPED_API_KEY=$(printf '%s' "$API_KEY" | sed 's/[&|\\]/\\&/g')

    sed -i \
        "s|__API_KEY__|${ESCAPED_API_KEY}|g" \
        /data/config.yaml
else
    sed -i '/__API_KEY__/d' /data/config.yaml
fi

echo "======================================"
echo "CLIProxyAPI starting"
echo "======================================"
echo "Port: ${PORT}"
echo "Config: /data/config.yaml"
echo "Auth: /data/auth"
echo "Management: enabled"
echo "======================================"

# IMPORTANT:
# MANAGEMENT_PASSWORD is supplied directly by Render.
# Do NOT write it into config.yaml.

exec /CLIProxyAPI/CLIProxyAPI --config /data/config.yaml
