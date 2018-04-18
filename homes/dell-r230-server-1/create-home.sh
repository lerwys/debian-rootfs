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
IMAGE_VERSION=1.0.2-debian-9.2
DMM7510_INSTANCE=ICT1
DMM7510_IP=10.2.117.31
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
IMAGE_VERSION=1.0.2-debian-9.2
DMM7510_INSTANCE=ICT2
DMM7510_IP=10.2.117.33
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

###############################################################################
# Configure compose IOC #3
###############################################################################

mkdir -p ${HOMEDIR}/03-sinap-timing-epics-ioc

# Configure env-files
bash -c "cat << "EOF" > ${HOMEDIR}/03-sinap-timing-epics-ioc/.env
IMAGE_VERSION=0.1.0-debian-9.2
SINAP_TIMING_INSTANCE=EVG1
SINAP_TIMING_IP=10.2.117.35
SINAP_TIMING_PORT=50111
SINAP_TIMING_AREA_PREFIX=AS-Glob:
SINAP_TIMING_DEVICE_PREFIX=TI-EVG:
EOF
"

# Configure homes
bash -c "cat << "EOF" > ${HOMEDIR}/03-sinap-timing-epics-ioc/00-sinap-timing-epics-ioc.yml
version: '3.4'

services:
  sinap-timing-epics-ioc:
    image: dockerregistry.lnls-sirius.com.br/sinap-timing-epics-ioc:\\\${IMAGE_VERSION}
    container_name: sinap-timing-epics-ioc-\\\${SINAP_TIMING_INSTANCE}
    command: \"\\\\
        -i \\\${SINAP_TIMING_IP} \\\\
        -p \\\${SINAP_TIMING_PORT} \\\\
        -d \\\${SINAP_TIMING_INSTANCE} \\\\
        -P \\\${SINAP_TIMING_AREA_PREFIX} \\\\
        -R \\\${SINAP_TIMING_DEVICE_PREFIX}\"
    volumes:
      - type: bind
        source: ${EPICSAUTOSAVE}
        target: /opt/epics/startup/ioc/sinap-timing-epics-ioc/iocBoot/ioctiming/autosave
    network_mode: \"host\"
EOF
"

###############################################################################
# Configure compose IOC #4
###############################################################################

mkdir -p ${HOMEDIR}/04-sinap-timing-epics-ioc

# Configure env-files
bash -c "cat << "EOF" > ${HOMEDIR}/04-sinap-timing-epics-ioc/.env
IMAGE_VERSION=0.1.0-debian-9.2
SINAP_TIMING_INSTANCE=EVE1
SINAP_TIMING_IP=10.2.117.34
SINAP_TIMING_PORT=50124
SINAP_TIMING_AREA_PREFIX=AS-Glob:
SINAP_TIMING_DEVICE_PREFIX=TI-EVE-1:
EOF
"

# Configure homes
bash -c "cat << "EOF" > ${HOMEDIR}/04-sinap-timing-epics-ioc/00-sinap-timing-epics-ioc.yml
version: '3.4'

services:
  sinap-timing-epics-ioc:
    image: dockerregistry.lnls-sirius.com.br/sinap-timing-epics-ioc:\\\${IMAGE_VERSION}
    container_name: sinap-timing-epics-ioc-\\\${SINAP_TIMING_INSTANCE}
    command: \"\\\\
        -i \\\${SINAP_TIMING_IP} \\\\
        -p \\\${SINAP_TIMING_PORT} \\\\
        -d \\\${SINAP_TIMING_INSTANCE} \\\\
        -P \\\${SINAP_TIMING_AREA_PREFIX} \\\\
        -R \\\${SINAP_TIMING_DEVICE_PREFIX}\"
    volumes:
      - type: bind
        source: ${EPICSAUTOSAVE}
        target: /opt/epics/startup/ioc/sinap-timing-epics-ioc/iocBoot/ioctiming/autosave
    network_mode: \"host\"
EOF
"

###############################################################################
# Configure compose IOC #4
###############################################################################

mkdir -p ${HOMEDIR}/05-sinap-timing-epics-ioc

# Configure env-files
bash -c "cat << "EOF" > ${HOMEDIR}/05-sinap-timing-epics-ioc/.env
IMAGE_VERSION=0.1.0-debian-9.2
SINAP_TIMING_INSTANCE=EVR1
SINAP_TIMING_IP=10.2.117.37
SINAP_TIMING_PORT=50125
SINAP_TIMING_AREA_PREFIX=AS-Glob:
SINAP_TIMING_DEVICE_PREFIX=TI-EVE-1:
EOF
"

# Configure homes
bash -c "cat << "EOF" > ${HOMEDIR}/05-sinap-timing-epics-ioc/00-sinap-timing-epics-ioc.yml
version: '3.4'

services:
  sinap-timing-epics-ioc:
    image: dockerregistry.lnls-sirius.com.br/sinap-timing-epics-ioc:\\\${IMAGE_VERSION}
    container_name: sinap-timing-epics-ioc-\\\${SINAP_TIMING_INSTANCE}
    command: \"\\\\
        -i \\\${SINAP_TIMING_IP} \\\\
        -p \\\${SINAP_TIMING_PORT} \\\\
        -d \\\${SINAP_TIMING_INSTANCE} \\\\
        -P \\\${SINAP_TIMING_AREA_PREFIX} \\\\
        -R \\\${SINAP_TIMING_DEVICE_PREFIX}\"
    volumes:
      - type: bind
        source: ${EPICSAUTOSAVE}
        target: /opt/epics/startup/ioc/sinap-timing-epics-ioc/iocBoot/ioctiming/autosave
    network_mode: \"host\"
EOF
"
