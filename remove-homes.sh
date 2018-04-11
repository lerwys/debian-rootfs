#!/usr/bin/env bash

set -euxo pipefail

TOPDIR=$1
HOMESREL=home
HOMES=${TOPDIR}/${HOMESREL}

CURDIR="$(dirname $(readlink -f $0))"

rm -rf ${HOMES}
