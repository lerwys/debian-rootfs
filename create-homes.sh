#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

. ${SCRIPTPATH}/env-vars.sh

## Begin Installation of HOMES

# Create homes dirs
for home in "${HOMES[@]}"; do
    mkdir -p ${home}
done

# Get ID/GID of generic user
GENERIC_ID=$(sudo chroot ${ROOTFS} id -u ${GENERIC_USER})
GENERIC_GID=$(sudo chroot ${ROOTFS} id -g ${GENERIC_USER})

################################################
### Just copy all of the files to the generated home
###############################################

for home in "${HOMESNAMES[@]}"; do
    cp --preserve -r ${HOMESNAMES_PREFIX}/${home}/* \
        ${HOMESFS}/${home}
    sudo chown ${GENERIC_ID}:${GENERIC_GID} -R \
        ${HOMESFS}/${home}
done
