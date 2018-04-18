#!/usr/bin/env bash

set -ue

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# Version
DOCKER_VERSION=18.03.0
DOCKER_VERSION_DEBIAN_SUFFIX=~ce-0~debian
DOCKER_COMPOSE_VERSION=1.21.0

# User modifiable
DEBIAN_URL="http://ftp.us.debian.org/debian"
DEBIAN_FLAVOR=stretch
ROOTFSREL=rootfs
HOMESREL=home
GENERIC_USER=server
AUTOSAVE_NAME=autosave
HOMEFS_IP="nfshome.lnls-sirus.com.br"
AUTOSAVEFS_IP="nfsautosave.lnls-sirus.com.br"

# Flavored variables
EXPORTDIR=exports
TOPDIR=${SCRIPTPATH}/${EXPORTDIR}
ROOTFS=${TOPDIR}/${ROOTFSREL}

# Home variables
HOMESFS=${TOPDIR}/${HOMESREL}
HOMESNAMES_PREFIX="homes"
HOMESNAMES_STR=$(ls ${SCRIPTPATH}/${HOMESNAMES_PREFIX})
HOMESNAMES=(${HOMESNAMES_STR})
EPICSAUTOSAVE="/media/autosave"

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
