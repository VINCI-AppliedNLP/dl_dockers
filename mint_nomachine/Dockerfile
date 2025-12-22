FROM linuxmintd/mint22.2-amd64:latest

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker

# Install dependencies, SSH, and Cinnamon
# Replaced x2goserver with curl/wget for NoMachine installation
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        systemd systemd-sysv dbus dbus-x11 \
        x11-xserver-utils xorg xauth \
        cinnamon-desktop-environment \
        openssh-server \
        sudo wget curl ca-certificates locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and Install NoMachine (Free Version 9.x)
# Note: NoMachine does not have a stable "latest" redirect URL; verify version at nomachine.com
RUN curl -fSL "download.nomachine.com" -o /tmp/nomachine.deb \
    && dpkg -i /tmp/nomachine.deb \
    && rm /tmp/nomachine.deb

ENV INITRD=no
RUN mkdir -p /var/run/sshd

# Default user
ARG USER=myuser
ARG PASS=password
RUN useradd -m -s /bin/bash ${USER} \
    && echo "${USER}:${PASS}" | chpasswd \
    && adduser ${USER} sudo

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# NoMachine uses port 4000 by default; SSH uses 22
EXPOSE 4000 22

VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/sbin/init"]
