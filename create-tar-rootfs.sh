#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

. ${SCRIPTPATH}/env-vars.sh

# Setup rootfs only if not there
[ ! -z "$(ls -A ${ROOTFS})" ] || \
    ${SCRIPTPATH}/create-all.sh

sudo bash -c "\
    tar -cvpzf rootfs.tar.gz \
        --exclude=${ROOTFS}/tmp \
        --exclude=${ROOTFS}/mnt \
        --exclude=${ROOTFS}/run \
        --exclude=${ROOTFS}/media \
        --exclude=${ROOTFS}/var/cache/apt/archives \
        --exclude=${ROOTFS}/usr/src/linux-headers* \
        --exclude=${ROOTFS}/var/log \
        ${ROOTFS}
"
