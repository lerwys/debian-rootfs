#!/usr/bin/env bash

set -ue

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# Version
DOCKER_VERSION=18.03.0
DOCKER_COMPOSE_VERSION=1.21.0

# User modifiable
DEBIAN_URL="http://ftp.us.debian.org/debian"
DEBIAN_FLAVOR=stretch
ROOTFSREL=rootfs
HOMESREL=home
GENERIC_USER=server
ROOTFS_IP="192.168.2.12"

# Flavored variables
EXPORTDIR=exports
TOPDIR=${SCRIPTPATH}/${EXPORTDIR}
ROOTFS=${TOPDIR}/${ROOTFSREL}

# Home variables
HOMESFS=${TOPDIR}/${HOMESREL}
HOMESNAMES_PREFIX="homes"
HOMESNAMES_STR=$(ls ${SCRIPTPATH}/${HOMESNAMES_PREFIX})
HOMESNAMES=(${HOMESNAMES_STR})
EPICSAUTOSAVE="/media/local/autosave"

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
