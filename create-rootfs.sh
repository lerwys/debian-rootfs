#!/usr/bin/env bash

set -eu

TOPDIR=$1
DEBIAN_URL=$2
DEBIAN_FLAVOR=$3
ROOTFS=$4
GENERIC_USER=$5
ROOTFS_IP=$6

## Begin Installation of ROOTFS
sudo apt-get install -y \
    debootstrap \
    coreutils

# Create rootfs dir
mkdir -p ${ROOTFS}

# Setup rootfs only if not there
[ -z ${ROOTFS} ] && sudo debootstrap ${DEBIAN_FLAVOR} ${ROOTFS} ${DEBIAN_URL}

# Create users
sudo chroot ${ROOTFS} passwd root
sudo chroot ${ROOTFS} usermod -d /home/root root

sudo chroot ${ROOTFS} bash -c "id -u ${GENERIC_USER} &>/dev/null || adduser ${GENERIC_USER}"

# Setup special filesystems so some programs don't fail
# when installing
sudo ln -sf /proc/mounts ${ROOTFS}/etc/mtab
sudo ln -sf ${ROOTFS}/proc/self/fd ${ROOTFS}/dev/fd || true

sudo mount -t proc proc ${ROOTFS}/proc/ || true

# Install packages
sudo chroot ${ROOTFS} apt-get update
sudo chroot ${ROOTFS} apt-get install -y \
    udev \
    initramfs-tools \
    linux-image-amd64 \
    autofs \
    openssh-server \
    nfs-common

# Install Docker
./install-docker.sh ${ROOTFS} ${GENERIC_USER}

# Setup home mounts
sudo bash -c "echo -e "\n# Automount NFS partitions\n/home   /etc/auto.home" \
    >> ${ROOTFS}/etc/auto.master"
sudo bash -c "cat << EOF > ${ROOTFS}/etc/auto.home
${GENERIC_USER}   ${ROOTFS_IP}:/nfshome/\$HOST
EOF
"

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
none                 /etc/docker.rw   tmpfs   defaults   0 0
none                 /var/lib/docker   tmpfs   defaults   0 0
EOF
"

sudo bash -c "cat << EOF > ${ROOTFS}/etc/systemd/system/mount-docker-overlay.service
[Unit]
Description=Mount /etc/docker as an overlay fielsystem
RequiresMountsFor=/etc/docker.rw
Before=docker.service
Requires=docker.service

[Service]
ExecStart=/bin/sh -c " \
    /bin/mkdir -p /etc/docker.rw/rw && \
    /bin/mkdir -p /etc/docker.rw/workdir && \
    /bin/mount -t overlay overlay \
        -olowerdir=/etc/docker,upperdir=/etc/docker.rw/rw,workdir=/etc/docker.rw/workdir /etc/docker \
"

[Install]
WantedBy=multi-user.target
EOF
"

sudo chroot ${ROOTFS} systemctl enable mount-docker-overlay

# Setup network
sudo bash -c "echo "${ROOTFS_IP} digdockerregistry.com.br" >> ${ROOTFS}/etc/hosts"

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
