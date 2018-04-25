#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

. ${SCRIPTPATH}/env-vars.sh

# Check if repo was cloned with Homes Filesystem submodule
[ ! -z "$(ls -A ${SCRIPTPATH}/${SUBMODULES}/${DEBIAN_HOMEFS_REPO})" ] || \
    git submodule update --init

## Begin Installation of HOMES

# Get all folder in depth exactly 1
HOMESNAMES_STR=$(find -L ${SCRIPTPATH}/${HOMESNAMES_PREFIX} \
    -maxdepth 1 -mindepth 1 -type d -iname "*" -exec basename '{}' \;| sort)
HOMESNAMES=(${HOMESNAMES_STR})

# Prefix homes array
HOMES=()
for homes in "${HOMESNAMES[@]}"; do
    HOMES+=(${HOMESFS}/${homes})
done

# Prefix homes build array
HOMESNAMES_FULL=()
for homes in "${HOMESNAMES[@]}"; do
    HOMESNAMES_FULL+=(${HOMESNAMES_PREFIX}/${homes})
done

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
