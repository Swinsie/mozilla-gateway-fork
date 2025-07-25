FROM node:20-bookworm-slim

EXPOSE 8080 4443

ARG DEBIAN_FRONTEND=noninteractive
RUN set -x && \
    apt update && \
    apt dist-upgrade -y && \
    apt install -y \
        arping \
        autoconf \
        build-essential \
        ffmpeg \
        git \
        iputils-ping \
        libcap2-bin \
        libdbus-1-dev \
        libffi-dev \
        libnss-mdns \
        libpng-dev \
        libtool \
        lsb-release \
        mosquitto \
        net-tools \
        pipx \
        pkg-config \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-six \
        python-is-python3 \
        sudo \
        zlib1g-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -g 997 gpio && \
    usermod -a -G sudo,dialout,gpio node && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY --chown=node:node . /home/node/webthings/gateway/
RUN pipx install cookiecutter && \
    pipx runpip cookiecutter install -r \
    /home/node/webthings/gateway/requirements.txt

USER node
WORKDIR /home/node/webthings/gateway
RUN set -x && \
    CPPFLAGS="-DPNG_ARM_NEON_OPT=0" npm ci && \
    npm run build && \
    rm -rf ./node_modules/gifsicle && \
    rm -rf ./node_modules/mozjpeg && \
    npm prune --production && \
    sed -i \
        -e 's/ behindForwarding: true/ behindForwarding: false/' \
        config/default.js

USER root
RUN cp /home/node/webthings/gateway/tools/udevadm /bin/udevadm && \
    cp /home/node/webthings/gateway/docker/avahi-daemon.conf /etc/avahi/ && \
    cp /home/node/webthings/gateway/docker/init.sh /

ENTRYPOINT ["/init.sh"]
