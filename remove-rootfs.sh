#!/usr/bin/env bash

set -eux

TOPDIR=$1
ROOTFSREL=rootfs
ROOTFS=${TOPDIR}/${ROOTFSREL}

sudo rm -rf ${ROOTFS}
