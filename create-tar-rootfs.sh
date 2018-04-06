#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

. ${SCRIPTPATH}/env-vars.sh

# Setup rootfs only if not there
[ ! -z "$(ls -A ${ROOTFS})" ] || \
    ${SCRIPTPATH}/create-rootfs.sh \
        ${TOPDIR} \
        ${DEBIAN_URL} \
        ${DEBIAN_FLAVOR} \
        ${ROOTFS} \
        ${GENERIC_USER} \
        ${ROOTFS_IP}

bash -c "\
    cd ${ROOTFS} && \
    sudo tar -cvpzf rootfs.tar.gz \
        --exclude=./rootfs.tar.gz \
        --exclude=./tmp \
        --exclude=./mnt \
        --exclude=./run \
        --exclude=./media \
        --exclude=./var/cache/apt/archives \
        --exclude=./usr/src/linux-headers* \
        --exclude=./var/log \
        . && \
        mv rootfs.tar.gz ${SCRIPTPATH}
"
