#!/usr/bin/env bash

set -eu

# User modifiable
DEBIAN_URL="http://ftp.us.debian.org/debian"
DEBIAN_FLAVOR=stretch
ROOTFSREL=rootfs
GENERIC_USER=server
ROOTFS_IP="192.168.2.12"

# Flavored variables
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
EXPORTDIR=exports
TOPDIR=${SCRIPTPATH}/${EXPORTDIR}
ROOTFS=${TOPDIR}/${ROOTFSREL}

# Ask sudo password only once and
# keep updating sudo timestamp to
# avoid asking again
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || \
    exit; done 2>/dev/null &

# Setup rootfs
./create-rootfs.sh \
    ${TOPDIR} \
    ${DEBIAN_URL} \
    ${DEBIAN_FLAVOR} \
    ${ROOTFS} \
    ${GENERIC_USER} \
    ${ROOTFS_IP}

# Setup homes
./create-homes.sh \
    ${TOPDIR}
