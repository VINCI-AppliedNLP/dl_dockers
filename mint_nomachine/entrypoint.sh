#!/bin/bash
set -e

# Setup USER & PASS from environment variables
USER=${VNC_USER:-myuser}
PASS=${VNC_PASSWORD:-password}

# If user doesn't exist, create and set password
if ! id -u "$USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$USER"
fi

echo "$USER:$PASS" | chpasswd
usermod -aG sudo "$USER" || true

# Ensure SSH runtime dir exists
mkdir -p /var/run/sshd

# --- NoMachine Specific Startup ---
# Explicitly start the NoMachine server service
# This ensures the NX protocol is listening on port 4000
/usr/NX/bin/nxserver --startup

# Optional: Set Cinnamon as the default desktop for NoMachine
# If not set, NoMachine typically detects the installed environment automatically
sed -i '/DefaultDesktopCommand/c\DefaultDesktopCommand "/usr/bin/gnome-session-cinnamon"' /usr/NX/etc/node.cfg

# Start systemd (PID 1)
# Using exec replaces this process so the container runs systemd as the primary init
exec /sbin/init