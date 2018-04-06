#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

. ${SCRIPTPATH}/env-vars.sh

# Setup rootfs only if not there
[ ! -z "$(ls -A ${HOMESFS})" ] || \
    ${SCRIPTPATH}/create-homes.sh \
        ${TOPDIR} \
        ${HOMES[@]}

bash -c "\
    cd ${HOMESFS} && \
    tar -cvpzf homefs.tar.gz \
        --exclude=./homefs.tar.gz \
        . && \
    mv homefs.tar.gz ${SCRIPTPATH}
"
