#!/usr/bin/env bash

set -ue

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# Version
DOCKER_VERSION=18.03.0
DOCKER_VERSION_DEBIAN_SUFFIX=~ce-0~debian
DOCKER_COMPOSE_VERSION=1.21.0

# User modifiable
DEBIAN_URL="http://ftp.us.debian.org/debian"
DEBIAN_FLAVOR=stretch
ROOTFSREL=rootfs
HOMESREL=home
GENERIC_USER=server
AUTOSAVE_NAME=autosave
HOMEFS_IP="nfshome.lnls-sirius.com.br"
AUTOSAVEFS_IP="nfsautosave.lnls-sirius.com.br"

# Subdmoules
SUBMODULES="foreign"
DOCKER_REGISTRY_CERTS_REPO="docker-registry-certs"
DEBIAN_HOMEFS_REPO="debian-homefs"

# Flavored variables
EXPORTDIR=exports
TOPDIR=${SCRIPTPATH}/${EXPORTDIR}
ROOTFS=${TOPDIR}/${ROOTFSREL}

# Home variables
HOMESFS=${TOPDIR}/${HOMESREL}
HOMESNAMES_PREFIX="homes"
EPICSAUTOSAVE="/media/autosave"

