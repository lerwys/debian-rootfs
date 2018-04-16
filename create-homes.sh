#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

. ${SCRIPTPATH}/env-vars.sh

## Begin Installation of HOMES

# Create homes dirs
for home in "${HOMES[@]}"; do
    mkdir -p ${home}
done

################################################
### Configure start/stop scripts
###############################################

DEFAULT_SCRIPTS=()
DEFAULT_SCRIPTS+=("boot-start-pre-container-apps.sh")
DEFAULT_SCRIPTS+=("boot-start-post-container-apps.sh")
DEFAULT_SCRIPTS+=("boot-stop-pre-container-apps.sh")
DEFAULT_SCRIPTS+=("boot-stop-post-container-apps.sh")
DEFAULT_SCRIPTS+=("boot-start-pre-apps.sh")
DEFAULT_SCRIPTS+=("boot-start-post-apps.sh")
DEFAULT_SCRIPTS+=("boot-stop-pre-apps.sh")
DEFAULT_SCRIPTS+=("boot-stop-post-apps.sh")

# Configure default scripts
for home in "${HOMES[@]}"; do
    for scripts in "${DEFAULT_SCRIPTS[@]}"; do
        sudo bash -c "cat << "EOF" > ${home}/${scripts}
#!/usr/bin/env bash
EOF
"
    sudo chmod +x ${home}/${scripts}
    done
done

################################################
### Configure docker-compose folder
###############################################

for home in "${HOMESNAMES[@]}"; do
    ${HOMESNAMES_PREFIX}/${home}/create-home.sh \
        ${HOMESFS}/${home}
done
