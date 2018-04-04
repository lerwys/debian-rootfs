#!/usr/bin/env bash

set -euxo pipefail

TOPDIR=$1
DEBIAN_URL=$2
DEBIAN_FLAVOR=$3
ROOTFS=$4
GENERIC_USER=$5
ROOTFS_IP=$6

CURDIR="$(dirname $(readlink -f $0))"

## Begin Installation of ROOTFS
sudo apt-get install -y \
    debootstrap \
    coreutils

# Create rootfs dir
mkdir -p ${ROOTFS}

# Setup rootfs only if not there
[ ! -z "$(ls -A ${ROOTFS})" ] || sudo debootstrap ${DEBIAN_FLAVOR} ${ROOTFS} ${DEBIAN_URL}

# Create users
sudo chroot ${ROOTFS} passwd root
sudo chroot ${ROOTFS} usermod -d /home/root root

sudo chroot ${ROOTFS} bash -c "id -u ${GENERIC_USER} &>/dev/null || adduser ${GENERIC_USER}"
sudo chroot ${ROOTFS} adduser ${GENERIC_USER} sudo
sudo chroot ${ROOTFS} mkdir -p /home/${GENERIC_USER}

# Setup special filesystems so some programs don't fail
# when installing
sudo ln -sf /proc/mounts ${ROOTFS}/etc/mtab
sudo chroot ${ROOTFS} mount -t proc proc /proc
sudo mkdir -p ${ROOTFS}/proc/self/fd
sudo ln -sf /proc/self/fd ${ROOTFS}/dev || true

# Install packages
sudo chroot ${ROOTFS} apt-get update
sudo chroot ${ROOTFS} apt-get install -y \
    udev \
    coreutils \
    initramfs-tools \
    linux-image-amd64 \
    linux-headers-amd64 \
    autofs \
    thin-provisioning-tools \
    fuse \
    openssh-server \
    nfs-common \
    vim \
    git \
    ntp \
    resolvconf \
    dnsutils

# Install Docker
${CURDIR}/install-docker.sh ${ROOTFS} ${GENERIC_USER}

# Setup home mounts
AUTOFS_HOST='\$HOST'
sudo bash -c "echo -e '\n# Automount NFS partitions\n/home   /etc/auto.home' \
    >> ${ROOTFS}/etc/auto.master"
sudo bash -c "cat << EOF > ${ROOTFS}/etc/auto.home
${GENERIC_USER}   ${ROOTFS_IP}:/exports/home/${AUTOFS_HOST}
EOF
"

# Setup interfaces
NET_INTERFACE=()
NET_INTERFACE+=("eno1")

for interface in ${NET_INTERFACE[@]}; do
    sudo bash -c "cat << EOF > ${ROOTFS}/etc/network/interfaces.d/${interface}
auto ${interface}
iface ${interface} inet dhcp
EOF
    "
done

# Setup Docker special folder as we are in a NFS, and some folders
# need to be RW and others needs to be RW, but overlayied with
# some previous configuration files (like /etc/docker)
sudo bash -c "cat << EOF > ${ROOTFS}/etc/fstab
proc                 /proc      proc    defaults   0 0
/dev/nfs             /          nfs     tcp,nolock 0 0
none                 /tmp       tmpfs   defaults   0 0
none                 /var/tmp   tmpfs   defaults   0 0
none                 /media     tmpfs   defaults   0 0
none                 /var/log   tmpfs   defaults   0 0
none                 /var/lib/dhcp   tmpfs   defaults   0 0
none                 /etc/docker.rw   tmpfs   defaults   0 0
none                 /var/lib/docker   tmpfs   defaults   0 0
EOF
"

sudo bash -c "cat << EOF > ${ROOTFS}/etc/systemd/system/mount-docker-overlay.service
[Unit]
Description=Mount /etc/docker as an overlay filesystem
RequiresMountsFor=/etc/docker.rw
Before=docker.service
Requires=docker.service

[Service]
ExecStart=/bin/sh -c \" \\\\
    /bin/mkdir -p /etc/docker.rw/rw && \\\\
    /bin/mkdir -p /etc/docker.rw/workdir && \\\\
    /bin/mount -t overlay overlay \\\\
        -olowerdir=/etc/docker,upperdir=/etc/docker.rw/rw,workdir=/etc/docker.rw/workdir /etc/docker \\\\
\"

[Install]
WantedBy=multi-user.target
EOF
"

sudo chroot ${ROOTFS} systemctl enable mount-docker-overlay

# Add bootstrap script for homes
sudo bash -c "cat << EOF > ${ROOTFS}/etc/systemd/system/bootstrap-apps.service
[Unit]
Description=Bootstrap service to load applications
After=autofs.service
Wants=autofs.service
After=docker.service
Wants=docker.service
After=mount-docker-overlay.service
Requires=mount-docker-overlay.service

[Service]
ExecStart=/home/server/bootstrap-apps.sh

[Install]
WantedBy=multi-user.target
EOF
"

sudo chroot ${ROOTFS} systemctl enable bootstrap-apps

# Clear hostname as this will be assigned from DHCP server
sudo bash -c "echo \"\" > ${ROOTFS}/etc/hostname"

# Copy certificate into correct location
sudo mkdir -p ${ROOTFS}/etc/docker/certs.d/dockerregistry.lnls-sirius.com.br:443
sudo cp foreign/docker-registry-certs/certs/domain.crt \
    ${ROOTFS}/etc/docker/certs.d/dockerregistry.lnls-sirius.com.br:443/ca.crt

sudo cp foreign/docker-registry-certs/certs/domain.crt \
    ${ROOTFS}/usr/local/share/ca-certificates/dockerregistry.lnls-sirius.com.br.crt
sudo chroot ${ROOTFS} update-ca-certificates

# After setting up everything unmount special filesystems
sudo bash -c "chroot ${ROOTFS} umount /proc || true"
