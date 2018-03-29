#!/usr/bin/env bash

set -eu

TOPDIR=$1
HOMESREL=home
HOMES=${TOPDIR}/${HOMESREL}

rm -rf ${HOMES}
