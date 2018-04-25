#!/usr/bin/env bash

set -eu

# Flavored variables
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

. ${SCRIPTPATH}/env-vars.sh

# Ask sudo password only once and
# keep updating sudo timestamp to
# avoid asking again
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || \
    exit; done 2>/dev/null &

# Setup rootfs
${SCRIPTPATH}/create-rootfs.sh \

# Setup homes
${SCRIPTPATH}/create-homes.sh \
