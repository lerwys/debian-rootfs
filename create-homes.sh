#!/usr/bin/env bash

set -eux

TOPDIR=$1

HOMESREL=()
HOMESREL+=("home/dell-r230-server-1")
HOMESREL+=("home/dell-r230-server-2")

# Prefix homes array
HOMES=()
for homes in "${HOMESREL[@]}"; do
    HOMES+=(${TOPDIR}/${homes})
done

## Begin Installation of HOMES

# Create homes dirs
for home in "${HOMES[@]}"; do
    mkdir -p ${home}
done

# Configure homes
for home in "${HOMES[@]}"; do
    sudo bash -c "cat << EOF > ${home}/bootstrap-apps.sh
#!/usr/bin/env bash

set -ueo pipefail

DMM7510_INSTANCE=DCCT1
IMAGE_VERSION=debian-9

# Testing Image
/usr/bin/docker pull \
    digdockerregistry.com.br/dmm7510-epics-ioc:\${IMAGE_VERSION}

/usr/bin/docker create \
    -v /opt/epics/startup/ioc/dmm7510-epics-ioc/iocBoot/iocdmm7510/autosave \
    --name dmm7510-epics-ioc-\${DMM7510_INSTANCE}-volume \
    digdockerregistry.com.br/dmm7510-epics-ioc:\${IMAGE_VERSION} \
    2>/dev/null || true

/usr/bin/docker run \
    --net host \
    -t \
    --rm \
    --volumes-from dmm7510-epics-ioc-\${DMM7510_INSTANCE}-volume \
    --name dmm7510-epics-ioc-\${DMM7510_INSTANCE} \
    digdockerregistry.com.br/dmm7510-epics-ioc:\${IMAGE_VERSION} \
    -i 10.0.18.37 \
    -p 5025 \
    -d DCCT1 \
    -P TEST: \
    -R DCCT:
EOF
"

    sudo chmod 755 ${home}/bootstrap-apps.sh
done
