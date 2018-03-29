#!/usr/bin/env bash

set -eu

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
EXPORTDIR=exports
TOPDIR=${SCRIPTPATH}/${EXPORTDIR}

# Ask sudo password only once and
# keep updating sudo timestamp to
# avoid asking again
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || \
    exit; done 2>/dev/null &

# Remove rootfs
./remove-rootfs.sh ${TOPDIR}

# Remove homes
./remove-homes.sh ${TOPDIR}
