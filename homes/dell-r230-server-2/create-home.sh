#!/usr/bin/env bash

set -eux

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

. ${SCRIPTPATH}/../../env-vars.sh

HOMEDIR=$1

# Create compose directories
mkdir -p ${HOMEDIR}/00-dmm7510-epics-ioc

# Configure env-files
bash -c "cat << "EOF" > ${HOMEDIR}/00-dmm7510-epics-ioc/.env
IMAGE_VERSION=debian-9
DMM7510_INSTANCE=DCCT2
EOF
"

# Configure homes
bash -c "cat << "EOF" > ${HOMEDIR}/00-dmm7510-epics-ioc/00-dmm7510-epics-ioc.yml
version: '3.4'

services:
  dmm7510-epics-ioc:
    image: dockerregistry.lnls-sirius.com.br/dmm7510-epics-ioc:\\\${IMAGE_VERSION}
    container_name: dmm7510-epics-ioc-dcct-1
    command: \"-i 10.0.18.37 -p 5025 -d \\\${DMM7510_INSTANCE} -P TEST2: -R DCCT2:\"
    volumes:
      - type: bind
        source: ${EPICSAUTOSAVE}
        target: /opt/epics/startup/ioc/dmm7510-epics-ioc/iocBoot/iocdmm7510/autosave
    network_mode: \"host\"
EOF
"
