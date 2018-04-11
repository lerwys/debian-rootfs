#!/usr/bin/env bash

set -euxo pipefail

ROOTFS=$1
GENERIC_USER=$2

CURDIR="$(dirname $(readlink -f $0))"

## Begin Installation of Docker

sudo chroot ${ROOTFS} apt-get update
sudo chroot ${ROOTFS} apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    lvm2

sudo chroot ${ROOTFS} bash -c \
    "curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -"
sudo chroot ${ROOTFS} add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable"

# Install Docker package
sudo chroot ${ROOTFS} apt-get update
sudo chroot ${ROOTFS} apt-get install -y \
    docker-ce

# Add GENERIC_USER to docker group
sudo chroot ${ROOTFS} bash -c "getent group docker || groupadd docker"
sudo chroot ${ROOTFS} usermod -aG docker ${GENERIC_USER}

# Install docker-compose
sudo chroot ${ROOTFS} bash -c "[ -f /usr/local/bin/docker-compose ] || curl -L \
    https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` \
    -o /usr/local/bin/docker-compose"
sudo chroot ${ROOTFS} chmod +x /usr/local/bin/docker-compose

# Setup common Docker directories
sudo chroot ${ROOTFS} mkdir -p /var/lib/docker /etc/{docker,docker.rw}

# Use overlay as the default storage-driver
sudo bash -c "cat << EOF > ${ROOTFS}/etc/docker/daemon.json
{
  \"storage-driver\": \"overlay2\"
}
EOF
"
