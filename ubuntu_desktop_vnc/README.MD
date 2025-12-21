# Ubuntu Desktop with TigerVNC Server

This Docker image provides a full Ubuntu 24.04 desktop environment (GNOME) accessible via VNC with TLS security support.

## Features

- **Base Image**: Ubuntu 24.04 LTS
- **Desktop Environment**: GNOME (ubuntu-gnome-desktop)
- **VNC Server**: TigerVNC with TLS support
- **Security**: Runs as non-root user, TLS-enabled VNC
- **Default Resolution**: 1920x1080
- **Default VNC Port**: 5901

## Quick Start

### Build the Image

```bash
docker build -t ubuntu_desktop_vnc .
```

### Run the Container

```bash
docker run -d -p 5901:5901 --name ubuntu-desktop ubuntu_desktop_vnc
```

### Connect via VNC

Use any VNC client (e.g., TigerVNC Viewer, RealVNC, TightVNC) to connect:

- **Host**: `localhost:5901` or `<your-server-ip>:5901`
- **Default Password**: `password123`

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_USER` | `vncuser` | Username for the VNC session |
| `VNC_PASSWORD` | `password123` | VNC and user password |
| `VNC_RESOLUTION` | `1920x1080` | Screen resolution |
| `VNC_DEPTH` | `24` | Color depth (16, 24, or 32) |

### Custom User and Password

```bash
docker run -d -p 5901:5901 \
  -e VNC_USER=myuser \
  -e VNC_PASSWORD=mysecretpassword \
  ubuntu_desktop_vnc
```

### Custom Resolution

```bash
docker run -d -p 5901:5901 -e VNC_RESOLUTION=2560x1440 ubuntu_desktop_vnc
```

### Combined Example

```bash
docker run -d \
  --name ubuntu-desktop \
  -p 5901:5901 \
  -e VNC_USER=developer \
  -e VNC_PASSWORD=mysecretpassword \
  -e VNC_RESOLUTION=1920x1080 \
  -e VNC_DEPTH=24 \
  ubuntu_desktop_vnc
```

## Persisting Data

To persist user home directory data:

```bash
docker run -d \
  --name ubuntu-desktop \
  -p 5901:5901 \
  -v ubuntu_home:/home/vncuser \
  ubuntu_desktop_vnc
```

## Running with GPU Support (NVIDIA)

If you need GPU acceleration:

```bash
docker run -d \
  --name ubuntu-desktop \
  --gpus all \
  -p 5901:5901 \
  ubuntu_desktop_vnc
```

## Exposed Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 5901 | TCP | VNC Server (display :1) |

## VNC Clients

### Recommended VNC Clients

- **Windows**: [TigerVNC Viewer](https://tigervnc.org/), [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)
- **macOS**: Built-in Screen Sharing, [TigerVNC Viewer](https://tigervnc.org/)
- **Linux**: `vncviewer`, Remmina, TigerVNC Viewer

### Connect using TigerVNC Viewer (CLI)

```bash
vncviewer localhost:5901
```

## Accessing the Container Shell

To access the container shell as the VNC user:

```bash
docker exec -it -u vncuser ubuntu-desktop bash
```

To access as root:

```bash
docker exec -it ubuntu-desktop bash
```

## Troubleshooting

### VNC Connection Refused

1. Check if the container is running:
   ```bash
   docker ps
   ```

2. Check container logs:
   ```bash
   docker logs ubuntu-desktop
   ```

### Black Screen After Connection

This can happen if GNOME fails to start. Try:

1. Restart the container:
   ```bash
   docker restart ubuntu-desktop
   ```

2. Or exec into the container and restart VNC:
   ```bash
   docker exec -it ubuntu-desktop bash
   su - vncuser -c "vncserver -kill :1"
   su - vncuser -c "vncserver -geometry 1920x1080 -depth 24 -SecurityTypes VncAuth,TLSVnc :1"
   ```

### Performance Issues

- Reduce resolution: `-e VNC_RESOLUTION=1280x720`
- Reduce color depth: `-e VNC_DEPTH=16`
- Use a lighter desktop environment (consider creating a variant with XFCE or LXDE)

## Building with GitHub Actions

This image can be built using the repository's GitHub Actions workflow:

1. Go to **Actions** → **build_push_image**
2. Click **Run workflow**
3. Set `build_folder` to `ubuntu_desktop_vnc`
4. Set desired `tags` (e.g., `latest`)
5. Click **Run workflow**

## Security Features

- **Non-root user**: VNC session runs as a non-root user (`vncuser` by default)
- **TLS Support**: VNC connections support TLS encryption (`VncAuth,TLSVnc`)
- **Sudo access**: The VNC user has sudo privileges for administrative tasks

## Security Notes

⚠️ **Warning**: The default VNC password is `password123`. Always set a strong password using the `VNC_PASSWORD` environment variable in production environments.

⚠️ **Warning**: For secure remote access over untrusted networks, consider:
- Using SSH tunneling: `ssh -L 5901:localhost:5901 user@server`
- Setting up a VPN
- Using a reverse proxy with TLS

## Files in this Directory

| File | Description |
|------|-------------|
| `Dockerfile` | Docker image definition |
| `entrypoint.sh` | Container entrypoint script that sets up user and starts VNC |
| `README.MD` | This documentation file |

## License

This Dockerfile is provided as-is for educational and development purposes.
