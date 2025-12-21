FROM ubuntu:24.04
LABEL maintainer="VA"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    VNC_RESOLUTION=1920x1080 \
    VNC_DEPTH=24 \
    VNC_USER=vncuser \
    VNC_PASSWORD=password123

# Install required packages
RUN apt-get update && apt-get install -y \
    ubuntu-gnome-desktop \
    gnome-shell \
    gnome-session \
    tigervnc-standalone-server \
    tigervnc-common \
    dbus-x11 \
    x11-xserver-utils \
    xauth \
    xfce4-terminal \
    sudo \
    wget \
    curl \
    nano \
    vim \
    net-tools \
    locales \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Generate locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose VNC port
EXPOSE 5901

# Use entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
