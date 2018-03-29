#!/usr/bin/env bash

set -eux

TOPDIR=$1
HOMESREL=home
HOMES=${TOPDIR}/${HOMESREL}

rm -rf ${HOMES}
