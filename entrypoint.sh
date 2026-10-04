#!/bin/sh
set -eu

PORT="${PORT:-8317}"
TZ="${TZ:-Asia/Dhaka}"

export TZ
export HOME=/data

mkdir -p /data/auth
mkdir -p /data/plugins
mkdir -p /data/logs

# Persist CLIProxyAPI authentication data
mkdir -p /root

if [ ! -e /root/.cli-proxy-api ]; then
    ln -s /data/auth /root/.cli-proxy-api
fi

# Create persistent configuration on first startup
if [ ! -f /data/config.yaml ]; then
    cp /CLIProxyAPI/config.template.yaml /data/config.yaml
fi

# Update server port
sed -i "s/^  port: .*/  port: ${PORT}/" /data/config.yaml

# Set management key only if the placeholder is still present
if [ -n "${MANAGEMENT_KEY:-}" ]; then
    ESCAPED_KEY=$(printf '%s' "$MANAGEMENT_KEY" | sed 's/[&|\\]/\\&/g')

    sed -i \
        "s|__MANAGEMENT_KEY__|${ESCAPED_KEY}|g" \
        /data/config.yaml
fi

# Set client API key
if [ -n "${API_KEY:-}" ]; then
    ESCAPED_API_KEY=$(printf '%s' "$API_KEY" | sed 's/[&|\\]/\\&/g')

    sed -i \
        "s|__API_KEY__|${ESCAPED_API_KEY}|g" \
        /data/config.yaml
else
    sed -i '/__API_KEY__/d' /data/config.yaml
fi

echo "========================================"
echo "CLIProxyAPI"
echo "========================================"
echo "Port: ${PORT}"
echo "Config: /data/config.yaml"
echo "Auth: /data/auth"
echo "Management API: enabled"
echo "========================================"

exec /CLIProxyAPI/CLIProxyAPI --config /data/config.yaml
