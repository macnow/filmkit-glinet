# filmkit-glinet

Integration build for deploying [FilmKit](https://github.com/macnow/filmkit) to GL.inet routers.

Combines the FilmKit web app with [filmkit-daemon](https://github.com/macnow/filmkit-daemon) — a USB-to-HTTP bridge that runs on the router and lets any browser (including iOS/iPadOS) edit Fujifilm camera presets and convert RAW files over local Wi-Fi.

## How it works

```
Your phone/laptop browser
        │  HTTP  (Wi-Fi, port 8765)
        ▼
GL.inet router
  └─ filmkit-daemon      ← this repo builds + deploys this
  └─ /www/filmkit/       ← FilmKit web app served as static files
        │  PTP/USB
        ▼
Fujifilm camera (USB-C)
```

## Tested hardware

| Router | Camera |
|--------|--------|
| GL.inet GL-BE9300 | X100VI |
| GL.inet GL-E5800 | X100VI |

## Prerequisites

- **Node.js** (for building the frontend)
- **Go 1.21+** (for building the daemon)
- **aarch64 cross-compiler** (`make install-cross` in `filmkit-daemon/`)
- **Static libusb** compiled for `arm64-linux-musl` (see `filmkit-daemon/README.md`)
- **SSH access** to your GL.inet router (root, key-based recommended)

## Quick start

```sh
# 1. Clone with submodules
git clone --recursive https://github.com/macnow/filmkit-glinet.git
cd filmkit-glinet

# 2. Install cross-compiler (macOS, one-time)
make -C filmkit-daemon install-cross

# 3. Build + deploy everything
make deploy ROUTER_IP=10.0.1.1

# 4. Open in browser
open http://10.0.1.1:8765
```

## Makefile targets

| Target | Description |
|--------|-------------|
| `make build` | Build frontend + daemon |
| `make build-frontend` | Build FilmKit web app only (`npm run build`) |
| `make build-daemon` | Cross-compile daemon for router only |
| `make deploy` | Build everything and deploy to router |
| `make deploy-frontend` | Deploy frontend only (fast, no recompile) |
| `make deploy-daemon` | Deploy daemon binary + init script only |
| `make clean` | Remove `filmkit/dist` and `filmkit-daemon/dist` |

All targets accept `ROUTER_IP` and `ROUTER_USER` overrides:
```sh
make deploy ROUTER_IP=192.168.8.1 ROUTER_USER=root
```

## Submodules

| Path | Repo | Role |
|------|------|------|
| `filmkit/` | [macnow/filmkit](https://github.com/macnow/filmkit) | Web app (fork of eggricesoy/filmkit with router mode) |
| `filmkit-daemon/` | [macnow/filmkit-daemon](https://github.com/macnow/filmkit-daemon) | HTTP daemon (Go, PTP/USB, REST API) |

To update to the latest versions of both:
```sh
git submodule update --remote
```

## Camera setup

Connect the camera in **USB Raw Conv./Backup Restore** mode:
> Camera menu → Network/USB Setting → Connection Mode → USB Raw Conv./Backup Restore

This enables preset editing. In standard PTP mode the camera connects but preset editing is unavailable.

## License

MIT.
