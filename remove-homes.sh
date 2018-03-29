#!/usr/bin/env bash

set -eux

TOPDIR=$1
HOMESREL=home
HOMES=${TOPDIR}/${HOMESREL}

CURDIR="$(dirname $(readlink -f $0))"

rm -rf ${HOMES}
