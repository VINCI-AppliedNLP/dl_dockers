GNOME + X2Go Docker image (experimental)

Purpose
- Provide a starting Dockerfile for running GNOME desktop with X2Go (NX over SSH).
- Notes below explain caveats and how to run the container with systemd/logind enabled.

Caveats / important notes
- GNOME expects systemd/logind and normally runs on Wayland by default. X2Go uses X11.
  - We force GNOME to prefer Xorg by setting Wayland disabled in `/etc/gdm3/custom.conf` and using `XDG_SESSION_TYPE=x11`.
- To run GNOME reliably you usually must run systemd as PID 1 inside the container and provide cgroup mounts and additional privileges.
  - This increases complexity and reduces portability/security of the container.
- If you only need a desktop for remote use, `xfce4` or `mate` are far more reliable inside containers and are recommended for production VMs/containers.

Build

```bash
docker build -t brokenjade/mint_x2go:latest ./ubuntu_desktop_vnc/gnome_x2go
```

Run (recommended for testing)

This runs systemd inside the container. The flags below are commonly required; they loosen isolation and may not be suitable for all environments.

```bash
docker run --privileged -d \
  --tmpfs /run --tmpfs /run/lock \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -p 2222:22 \
  -e VNC_USER=myuser -e VNC_PASSWORD='yourpass' \
  --name gnome-x2go gnome-x2go:latest
```

Notes after starting
- The container will run `systemd` as PID 1. You can view logs with `docker logs` and `docker exec -it <container> journalctl -f`.
- Ensure `sshd` and `x2goserver` are running inside the container. If not:

```bash
docker exec -it <container> bash
# inside container
systemctl enable --now ssh x2goserver
systemctl status ssh x2goserver
```

Connect with X2Go
- Install `x2goclient` on your host.
- Create a new session connecting to `localhost:2222` using the `SSH` transport and the user you set (`myuser` / `yourpass`).
- Choose the session type `Custom` and set the command to `gnome-session` or select `GNOME` if available.

Troubleshooting
- If `gnome-session` exits immediately:
  - Check `journalctl -u gdm` and `journalctl -xe` for errors related to logind, dbus, or the compositor (Mutter).
  - Some errors indicate missing devices (`/dev/dri`) or permissions — consider adding `--device /dev/dri` and GPU-related mounts if you need hardware acceleration.
  - If systemd/logind errors persist, consider using a lightweight DE (XFCE/MATE) for X2Go.

Alternatives
- For a robust containerized desktop, use XFCE + X2Go or TigerVNC + XFCE (lighter, simpler).
- For full GNOME experience, run on a VM or a systemd-enabled host with real device access.

Security
- Running with `--privileged` and exposing SSH increases attack surface. Lock down passwords, use SSH keys, or run behind a firewall.

