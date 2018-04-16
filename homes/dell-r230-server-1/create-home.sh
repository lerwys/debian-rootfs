#!/usr/bin/env bash

set -eux

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

. ${SCRIPTPATH}/../../env-vars.sh

HOMEDIR=$1

###############################################################################
# Configure compose IOC #1
###############################################################################

# Create compose directories
mkdir -p ${HOMEDIR}/00-dmm7510-epics-ioc

# Configure env-files
bash -c "cat << "EOF" > ${HOMEDIR}/00-dmm7510-epics-ioc/.env
IMAGE_VERSION=1.0.1-debian-9.2
DMM7510_INSTANCE=ICT1
DMM7510_IP=10.0.18.31
DMM7510_PORT=5025
DMM7510_AREA_PREFIX=TS-01:
DMM7510_DEVICE_PREFIX=DI-ICT:
EOF
"

# Configure homes
bash -c "cat << "EOF" > ${HOMEDIR}/00-dmm7510-epics-ioc/00-dmm7510-epics-ioc.yml
version: '3.4'

services:
  dmm7510-epics-ioc:
    image: dockerregistry.lnls-sirius.com.br/dmm7510-epics-ioc:\\\${IMAGE_VERSION}
    container_name: dmm7510-epics-ioc-\\\${DMM7510_INSTANCE}
    command: \"\\\\
        -i \\\${DMM7510_IP} \\\\
        -p \\\${DMM7510_PORT} \\\\
        -d \\\${DMM7510_INSTANCE} \\\\
        -P \\\${DMM7510_AREA_PREFIX} \\\\
        -R \\\${DMM7510_DEVICE_PREFIX}\"
    volumes:
      - type: bind
        source: ${EPICSAUTOSAVE}
        target: /opt/epics/startup/ioc/dmm7510-epics-ioc/iocBoot/iocdmm7510/autosave
    network_mode: \"host\"
EOF
"

###############################################################################
# Configure compose IOC #2
###############################################################################

mkdir -p ${HOMEDIR}/01-dmm7510-epics-ioc

# Configure env-files
bash -c "cat << "EOF" > ${HOMEDIR}/01-dmm7510-epics-ioc/.env
IMAGE_VERSION=1.0.1-debian-9.2
DMM7510_INSTANCE=ICT2
DMM7510_IP=10.0.18.33
DMM7510_PORT=5025
DMM7510_AREA_PREFIX=TS-04:
DMM7510_DEVICE_PREFIX=DI-ICT:
EOF
"

# Configure homes
bash -c "cat << "EOF" > ${HOMEDIR}/01-dmm7510-epics-ioc/00-dmm7510-epics-ioc.yml
version: '3.4'

services:
  dmm7510-epics-ioc:
    image: dockerregistry.lnls-sirius.com.br/dmm7510-epics-ioc:\\\${IMAGE_VERSION}
    container_name: dmm7510-epics-ioc-\\\${DMM7510_INSTANCE}
    command: \"\\\\
        -i \\\${DMM7510_IP} \\\\
        -p \\\${DMM7510_PORT} \\\\
        -d \\\${DMM7510_INSTANCE} \\\\
        -P \\\${DMM7510_AREA_PREFIX} \\\\
        -R \\\${DMM7510_DEVICE_PREFIX}\"
    volumes:
      - type: bind
        source: ${EPICSAUTOSAVE}
        target: /opt/epics/startup/ioc/dmm7510-epics-ioc/iocBoot/iocdmm7510/autosave
    network_mode: \"host\"
EOF
"
