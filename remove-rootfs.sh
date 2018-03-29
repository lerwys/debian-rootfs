#!/usr/bin/env bash

set -eux

TOPDIR=$1
ROOTFSREL=rootfs
ROOTFS=${TOPDIR}/${ROOTFSREL}

sudo bash -c "chroot ${ROOTFS} umount /proc || true"
sudo rm -rf ${ROOTFS}
