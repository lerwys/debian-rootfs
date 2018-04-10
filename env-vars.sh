#!/usr/bin/env bash

set -ue

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

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

HOMESNAMES=()
HOMESNAMES+=("dell-r230-server-1")
HOMESNAMES+=("dell-r230-server-2")
EPICSAUTOSAVE="/media/local/autosave"

# Prefix homes array
HOMES=()
for homes in "${HOMESNAMES[@]}"; do
    HOMES+=(${HOMESFS}/${homes})
done
