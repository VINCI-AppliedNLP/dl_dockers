#!/bin/bash
set -e

# Simple entrypoint: allow setting USER & PASS at runtime via env,
# ensure SSH & X2Go services are available after systemd starts.

USER=${VNC_USER:-myuser}
PASS=${VNC_PASSWORD:-password}

# If user doesn't exist (e.g., runtime override), create and set password
if ! id -u "$USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$USER"
fi

echo "$USER:$PASS" | chpasswd
usermod -aG sudo "$USER" || true

# Ensure SSH runtime dir exists
mkdir -p /var/run/sshd

# Create minimal X session for X2Go if not present (GNOME may provide sessions)
XSESSION=/home/$USER/.xsession
if [ ! -f "$XSESSION" ]; then
    cat > "$XSESSION" <<'XSESS'
#!/bin/sh
# Start GNOME session on Xorg (may require systemd/logind features)
export XDG_SESSION_TYPE=x11
exec dbus-launch --exit-with-session gnome-session
XSESS
    chown $USER:$USER "$XSESSION"
    chmod +x "$XSESSION"
fi

# Start systemd (PID 1) — exec to replace this process so container runs systemd
exec /sbin/init
