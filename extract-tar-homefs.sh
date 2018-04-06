#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

. ${SCRIPTPATH}/env-vars.sh

HOMEFS_EXTRACT=homefs-extract

bash -c "\
    mkdir -p ${HOMEFS_EXTRACT} && \
    cd ${HOMEFS_EXTRACT} && \
    tar -xpvzf ../homefs.tar.gz
"
