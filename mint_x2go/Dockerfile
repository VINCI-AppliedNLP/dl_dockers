FROM linuxmintd/mint22.2-amd64:latest

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker

# Install systemd, X2Go, SSH, and ensure Cinnamon is present
# Mint images usually have Cinnamon, but adding it here ensures it's installed
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        systemd systemd-sysv dbus dbus-x11 \
        x11-xserver-utils xorg xauth \
        cinnamon-desktop-environment \
        openssh-server \
        x2goserver x2goserver-xsession \
        sudo wget ca-certificates locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Prevent systemd from failing at build-time
ENV INITRD=no

# Create SSH runtime dir
RUN mkdir -p /var/run/sshd

# Default user
ARG USER=myuser
ARG PASS=password
RUN useradd -m -s /bin/bash ${USER} \
    && echo "${USER}:${PASS}" | chpasswd \
    && adduser ${USER} sudo

# Copy your existing entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22

VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/sbin/init"]
