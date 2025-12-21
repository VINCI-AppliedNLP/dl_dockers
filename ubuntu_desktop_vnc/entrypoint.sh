#!/bin/bash
set -e

# Create user if it doesn't exist
if ! id -u "$VNC_USER" >/dev/null 2>&1; then
    echo "Creating user: $VNC_USER"
    useradd -m -s /bin/bash "$VNC_USER"
    echo "$VNC_USER:$VNC_PASSWORD" | chpasswd
    usermod -aG sudo "$VNC_USER"
    # Enable passwordless sudo for the VNC user
    echo "$VNC_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$VNC_USER
    chmod 440 /etc/sudoers.d/$VNC_USER
fi

# Set up VNC configuration directory
mkdir -p /home/$VNC_USER/.vnc
chown -R $VNC_USER:$VNC_USER /home/$VNC_USER

# Create VNC startup script
cat > /home/$VNC_USER/.vnc/xstartup << 'XSTART'
#!/bin/bash
xrdb $HOME/.Xresources 2>/dev/null || true
dbus-launch --exit-with-session gnome-session &
XSTART

chmod +x /home/$VNC_USER/.vnc/xstartup
chown $VNC_USER:$VNC_USER /home/$VNC_USER/.vnc/xstartup

# Set VNC password
echo "$VNC_PASSWORD" | vncpasswd -f > /home/$VNC_USER/.vnc/passwd
chmod 600 /home/$VNC_USER/.vnc/passwd
chown $VNC_USER:$VNC_USER /home/$VNC_USER/.vnc/passwd

echo "=========================================="
echo "Starting VNC server for user: $VNC_USER"
echo "VNC Password: $VNC_PASSWORD"
echo "Resolution: $VNC_RESOLUTION"
echo "Color Depth: $VNC_DEPTH"
echo "Connect to: <host-ip>:5901"
echo "=========================================="

# Start VNC server as the created user
su - $VNC_USER -c "vncserver -geometry $VNC_RESOLUTION -depth $VNC_DEPTH -SecurityTypes VncAuth,TLSVnc :1"

# Keep container running
tail -f /dev/null
