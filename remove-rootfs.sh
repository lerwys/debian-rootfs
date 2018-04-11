#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

. ${SCRIPTPATH}/env-vars.sh

sudo bash -c "chroot ${ROOTFS} umount /proc || true"
sudo rm -rf ${ROOTFS}
