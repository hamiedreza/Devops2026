FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install CA certificates
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Switch Ubuntu repositories to HTTPS
RUN sed -i \
    -e 's|http://archive.ubuntu.com/ubuntu|https://archive.ubuntu.com/ubuntu|g' \
    -e 's|http://security.ubuntu.com/ubuntu|https://security.ubuntu.com/ubuntu|g' \
    /etc/apt/sources.list

# Install desktop, XRDP and Wine dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    xrdp \
    xorgxrdp \
    dbus-x11 \
    sudo \
    wget \
    curl \
    wine \
    winbind \
    cabextract \
    && rm -rf /var/lib/apt/lists/*

# Create desktop user
RUN useradd -m -s /bin/bash trader \
    && usermod -aG sudo trader \
    && echo "startxfce4" > /home/trader/.xsession \
    && chown trader:trader /home/trader/.xsession \
    && adduser xrdp ssl-cert

# Configure working directory
WORKDIR /home/trader

# Add container startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 3389

ENTRYPOINT ["/entrypoint.sh"]
