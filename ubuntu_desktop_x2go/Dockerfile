FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker

# Install systemd, GNOME, X2Go and SSH
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        systemd systemd-sysv dbus dbus-x11 \
        x11-xserver-utils xorg xauth \
        gnome-session gnome-shell gdm3 \
        openssh-server \
        x2goserver x2goserver-xsession \
        sudo wget ca-certificates locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Prevent systemd from failing at build-time
ENV INITRD=no

# Create SSH runtime dir
RUN mkdir -p /var/run/sshd

# Default user (can be overridden at build-time)
ARG USER=myuser
ARG PASS=password
RUN useradd -m -s /bin/bash ${USER} \
    && echo "${USER}:${PASS}" | chpasswd \
    && adduser ${USER} sudo

# Force GNOME to prefer Xorg (GNOME on Wayland will not work with X2Go)
RUN sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf || true

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose SSH port for X2Go
EXPOSE 22

VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/sbin/init"]
