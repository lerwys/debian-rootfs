#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

. ${SCRIPTPATH}/env-vars.sh

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
    'curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -'
sudo chroot ${ROOTFS} bash -c \
    'add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable"'

# Install Docker package
sudo chroot ${ROOTFS} apt-get update
sudo chroot ${ROOTFS} apt-get install -y \
    docker-ce=${DOCKER_VERSION}${DOCKER_VERSION_DEBIAN_SUFFIX}

# Add GENERIC_USER to docker group
sudo chroot ${ROOTFS} bash -c "getent group docker || groupadd docker"
sudo chroot ${ROOTFS} usermod -aG docker ${GENERIC_USER}

# Install docker-compose
sudo chroot ${ROOTFS} bash -c "[ -f /usr/local/bin/docker-compose ] || curl -L \
    https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` \
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
