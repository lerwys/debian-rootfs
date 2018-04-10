#!/usr/bin/env bash

set -eux

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

# Configure start pre
for home in "${HOMES[@]}"; do
    sudo bash -c "cat << "EOF" > ${home}/bootstrap-start-pre-apps.sh
#!/usr/bin/env bash
mkdir -p ${EPICSAUTOSAVE}
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
