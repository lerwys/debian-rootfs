#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

. ${SCRIPTPATH}/env-vars.sh

ROOTFS_EXTRACT=rootfs-extract

bash -c "\
    mkdir -p ${ROOTFS_EXTRACT} && \
    cd ${ROOTFS_EXTRACT} && \
    sudo tar -xpvzf ../rootfs.tar.gz --numeric-owner
"
