#!/bin/sh
set -eu

PORT="${PORT:-8317}"
TZ="${TZ:-Asia/Dhaka}"

export TZ
export HOME=/data

mkdir -p /data/auth /data/logs /data/plugins

# CLIProxyAPI normally stores auth under /root/.cli-proxy-api.
# Keep that directory on Render's persistent disk.
mkdir -p /root
if [ ! -e /root/.cli-proxy-api ]; then
  ln -s /data/auth /root/.cli-proxy-api
elif [ -d /root/.cli-proxy-api ] && [ ! -L /root/.cli-proxy-api ]; then
  cp -a /root/.cli-proxy-api/. /data/auth/ 2>/dev/null || true
  rm -rf /root/.cli-proxy-api
  ln -s /data/auth /root/.cli-proxy-api
fi

# Generate the persistent config only on first boot.
# If the Management API later edits config.yaml, those edits are preserved.
if [ ! -f /data/config.yaml ]; then
  cp /CLIProxyAPI/config.template.yaml /data/config.yaml
fi

# Render injects PORT automatically. Keep the config aligned with it.
sed -i "s/^port: .*/port: ${PORT}/" /data/config.yaml

# If MANAGEMENT_KEY is provided, replace the placeholder only on first boot.
# Do not overwrite an existing key that the Management API may have hashed.
if [ -n "${MANAGEMENT_KEY:-}" ] && grep -q '__MANAGEMENT_KEY__' /data/config.yaml; then
  ESCAPED_KEY=$(printf '%s' "$MANAGEMENT_KEY" | sed 's/[&|\\]/\\&/g')
  sed -i "s|__MANAGEMENT_KEY__|${ESCAPED_KEY}|" /data/config.yaml
fi

# Configure the optional client API key only on first boot.
if [ -n "${API_KEY:-}" ] && grep -q '__API_KEY__' /data/config.yaml; then
  ESCAPED_API=$(printf '%s' "$API_KEY" | sed 's/[&|\\]/\\&/g')
  sed -i "s|__API_KEY__|${ESCAPED_API}|" /data/config.yaml
else
  sed -i '/- "__API_KEY__"/d' /data/config.yaml
fi

exec /CLIProxyAPI/CLIProxyAPI --config /data/config.yaml
