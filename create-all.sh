#!/usr/bin/env bash

set -eu

# Flavored variables
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

. ${SCRIPTPATH}/env-vars.sh

CURDIR="$(dirname $(readlink -f $0))"

# Ask sudo password only once and
# keep updating sudo timestamp to
# avoid asking again
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || \
    exit; done 2>/dev/null &

# Check if repo was cloned with submodules
[ ! -z "$(ls -A ./foreign/docker-registry-certs)" ] || \
    git submodule update --init

# Setup rootfs
${CURDIR}/create-rootfs.sh \
    ${TOPDIR} \
    ${DEBIAN_URL} \
    ${DEBIAN_FLAVOR} \
    ${ROOTFS} \
    ${GENERIC_USER} \
    ${ROOTFS_IP}

# Setup homes
${CURDIR}/create-homes.sh \
    ${TOPDIR} \
    ${HOMES[@]}
