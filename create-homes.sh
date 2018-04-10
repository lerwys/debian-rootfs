#!/usr/bin/env bash

set -eux

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"
TOPDIR=$1
shift 1
HOMES=("$@")

EPICS_AUTOSAVE="/media/local/autosave"

## Begin Installation of HOMES

# Create homes dirs
for home in "${HOMES[@]}"; do
    mkdir -p ${home}
done

# Configure start pre
for home in "${HOMES[@]}"; do
    sudo bash -c "cat << "EOF" > ${home}/bootstrap-start-pre-apps.sh
#!/usr/bin/env bash
mkdir -p ${EPICS_AUTOSAVE}
EOF
"

    sudo chmod +x ${home}/bootstrap-start-pre-apps.sh
done

# Configure start post
for home in "${HOMES[@]}"; do
    sudo bash -c "cat << "EOF" > ${home}/bootstrap-start-post-apps.sh
#!/usr/bin/env bash
EOF
"

    sudo chmod +x ${home}/bootstrap-start-post-apps.sh
done

# Configure env-files
for home in "${HOMES[@]}"; do
    sudo bash -c "cat << "EOF" > ${home}/00-dmm7510-epics-ioc.env
IMAGE_VERSION=debian-9
DMM7510_INSTANCE=DCCT1
EOF
"
done

# Configure homes
for home in "${HOMES[@]}"; do
    sudo bash -c "cat << "EOF" > ${home}/00-dmm7510-epics-ioc.yml
version: '3'

services:
  dmm7510-epics-ioc:
    image: dockerregistry.lnls-sirius.com.br/dmm7510-epics-ioc:\\\${IMAGE_VERSION}
    env_file:
      - 00-dmm7510-epics-ioc.env
    container_name: dmm7510-epics-ioc-dcct-1
    command: -i 10.0.18.37 -p 5025 -d \\\${DMM7510_INSTANCE} -P TEST: -R DCCT:
    volumes:
      - type: bind
        source: ${EPICS_AUTOSAVE}
        target: /opt/epics/startup/ioc/dmm7510-epics-ioc/iocBoot/iocdmm7510/autosave
    network_mode: \"host\"

volumes:
  dmm7510-autosave-volume:
EOF
"
done

# Configure stop pre
for home in "${HOMES[@]}"; do
    sudo bash -c "cat << "EOF" > ${home}/bootstrap-stop-pre-apps.sh
#!/usr/bin/env bash
EOF
"

    sudo chmod +x ${home}/bootstrap-stop-pre-apps.sh
done

# Configure stop post
for home in "${HOMES[@]}"; do
    sudo bash -c "cat << "EOF" > ${home}/bootstrap-stop-post-apps.sh
#!/usr/bin/env bash
EOF
"

    sudo chmod +x ${home}/bootstrap-stop-post-apps.sh
done
