# CLIProxyAPI — Render Deployment

A Render-ready Docker wrapper for [router-for-me/CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI).

## Deploy

1. Push this repository to GitHub.
2. In Render, create **New → Blueprint** and select the repository, or create a Docker Web Service.
3. If using Blueprint, `render.yaml` configures the service automatically.
4. Set the secret environment variable `MANAGEMENT_KEY` in Render.
5. Optionally set `API_KEY` to the API key you want clients to use.
6. Deploy.

The service listens on port **8317** and uses a Render persistent disk mounted at `/data`.

Authentication files and the generated config are stored under `/data`, so they survive container restarts/redeploys.

## Environment variables

- `MANAGEMENT_KEY` — required for remote Management API access.
- `API_KEY` — optional client API key. If omitted, no API key is configured by this wrapper.
- `PORT` — defaults to `8317`; Render normally supplies this automatically.
- `TZ` — defaults to `Asia/Dhaka`.

Do not commit real secrets to GitHub.

## Endpoints

After deployment:

- API base: `https://YOUR-SERVICE.onrender.com`
- Models: `https://YOUR-SERVICE.onrender.com/v1/models`
- Management panel: `https://YOUR-SERVICE.onrender.com/management.html`

The management API is enabled remotely and protected by `MANAGEMENT_KEY`.
