#!/usr/bin/env bash

set -eu

TOPDIR=$1
ROOTFSREL=rootfs
ROOTFS=${TOPDIR}/${ROOTFSREL}

sudo rm -rf ${ROOTFS}
