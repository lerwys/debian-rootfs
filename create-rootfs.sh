#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

. ${SCRIPTPATH}/env-vars.sh

# Check if repo was cloned with Docker Certs submodules
[ ! -z "$(ls -A ${SCRIPTPATH}/${SUBMODULES}/${DOCKER_REGISTRY_CERTS_REPO})" ] || \
    git submodule update --init

## Begin Installation of ROOTFS
sudo apt-get install -y \
    debootstrap \
    coreutils

# Create rootfs dir
mkdir -p ${ROOTFS}

# Setup rootfs only if not there
[ ! -z "$(ls -A ${ROOTFS})" ] || sudo debootstrap ${DEBIAN_FLAVOR} ${ROOTFS} ${DEBIAN_URL}

# Create users
sudo chroot ${ROOTFS} passwd root
sudo chroot ${ROOTFS} usermod -d /home/root root

sudo chroot ${ROOTFS} bash -c "id -u ${GENERIC_USER} &>/dev/null || adduser ${GENERIC_USER}"
sudo chroot ${ROOTFS} adduser ${GENERIC_USER} sudo
sudo chroot ${ROOTFS} mkdir -p /home/${GENERIC_USER}

# Setup special filesystems so some programs don't fail
# when installing
sudo ln -sf /proc/mounts ${ROOTFS}/etc/mtab
sudo chroot ${ROOTFS} mount -t proc proc /proc || true
sudo mkdir -p ${ROOTFS}/proc/self/fd
sudo ln -sf /proc/self/fd ${ROOTFS}/dev || true

# Install packages
sudo chroot ${ROOTFS} apt-get update
sudo chroot ${ROOTFS} apt-get install -y \
    udev \
    coreutils \
    initramfs-tools \
    linux-image-amd64 \
    linux-headers-amd64 \
    autofs \
    thin-provisioning-tools \
    fuse \
    openssh-server \
    net-tools \
    iptables \
    nfs-common \
    vim \
    git \
    ntp \
    resolvconf \
    telnet \
    dnsutils

# Install Docker
${SCRIPTPATH}/install-docker.sh

# Setup home mounts
AUTOFS_HOST='\$HOST'
sudo bash -c "echo -e '\n# Automount NFS partitions\n/home   /etc/auto.home' \
    >> ${ROOTFS}/etc/auto.master"
sudo bash -c "echo -e '\n# Automount NFS partitions\n/media   /etc/auto.media' \
    >> ${ROOTFS}/etc/auto.master"

sudo bash -c "cat << EOF > ${ROOTFS}/etc/auto.home
${GENERIC_USER}   ${HOMEFS_IP}:/exports/home/${AUTOFS_HOST}
EOF
"
sudo bash -c "cat << EOF > ${ROOTFS}/etc/auto.media
${AUTOSAVE_NAME}   ${AUTOSAVEFS_IP}:/exports/autosave/${AUTOFS_HOST}
EOF
"

###############################################################################
# Setup interfaces
###############################################################################

NET_INTERFACE=()
NET_INTERFACE+=("eno1")
NET_INTERFACE+=("eno2")

for interface in ${NET_INTERFACE[@]}; do
    sudo bash -c "cat << EOF > ${ROOTFS}/etc/network/interfaces.d/${interface}
allow-hotplug ${interface}
no-auto-down ${interface}
iface ${interface} inet dhcp
EOF
    "
done

# Create special policy for broadcasting special packets. This is important
# to EPICS search requests, as multiple IOCs might be running on each host
sudo bash -c "cat << "EOF" > ${ROOTFS}/etc/network/if-up.d/222epicsbcast
#!/bin/sh -e
# Called when an interface goes up / down

# Author: Ralph Lange <Ralph.Lange@gmx.de>

# Make any incoming Channel Access name resolution queries go to the broadcast address
# (to hit all IOCs on this host)

# Change this if you run CA on a non-standard port
PORT=5064

MODE=\"up\"

[ \"\\\$IFACE\" != \"lo\" ] || exit 0
[ \"\\\$IFACE\" != \"--all\" ] || exit 0

line=\\\`/sbin/ifconfig \\\$IFACE | grep \"inet \"\\\`

[ -z \"\\\$line\" ] && return 0

# Fedora ifconfig output
addr=\\\`echo \\\$line | sed -e 's/.*inet \([0-9.]*\).*/\1/'\\\`
bcast=\\\`echo \\\$line | sed -e 's/.*broadcast \([0-9.]*\).*/\1/'\\\`

if [ -z \"\\\$addr\" -o -z \"\\\$bcast\" ]
then
    # RHEL ifconfig output
    addr=\\\`echo \\\$line | sed -e 's/.*inet addr:\([0-9.]*\).*/\1/'\\\`
    bcast=\\\`echo \\\$line | sed -e 's/.*Bcast:\([0-9.]*\).*/\1/'\\\`
fi

[ -z \"\\\$addr\" -o -z \"\\\$bcast\" ] && return 1

if [ \"\\\$MODE\" = \"up\" ]
then
    /sbin/iptables -t nat -A PREROUTING -d \\\$addr -p udp --dport \\\$PORT -j DNAT --to-destination \\\$bcast
elif [ \"\\\$MODE\" = \"down\" ]
then
    /sbin/iptables -t nat -D PREROUTING -d \\\$addr -p udp --dport \\\$PORT -j DNAT --to-destination \\\$bcast
fi

exit 0
EOF
"

sudo chmod +x ${ROOTFS}/etc/network/if-up.d/222epicsbcast

sudo bash -c "cat << "EOF" > ${ROOTFS}/etc/network/if-down.d/222epicsbcast
#!/bin/sh -e
# Called when an interface goes up / down

# Author: Ralph Lange <Ralph.Lange@gmx.de>

# Make any incoming Channel Access name resolution queries go to the broadcast address
# (to hit all IOCs on this host)

# Change this if you run CA on a non-standard port
PORT=5064

MODE=\"down\"

[ \"\\\$IFACE\" != \"lo\" ] || exit 0
[ \"\\\$IFACE\" != \"--all\" ] || exit 0

line=\\\`/sbin/ifconfig \\\$IFACE | grep \"inet \"\\\`

[ -z \"\\\$line\" ] && return 0

# Fedora ifconfig output
addr=\\\`echo \\\$line | sed -e 's/.*inet \([0-9.]*\).*/\1/'\\\`
bcast=\\\`echo \\\$line | sed -e 's/.*broadcast \([0-9.]*\).*/\1/'\\\`

if [ -z \"\\\$addr\" -o -z \"\\\$bcast\" ]
then
    # RHEL ifconfig output
    addr=\\\`echo \\\$line | sed -e 's/.*inet addr:\([0-9.]*\).*/\1/'\\\`
    bcast=\\\`echo \\\$line | sed -e 's/.*Bcast:\([0-9.]*\).*/\1/'\\\`
fi

[ -z \"\\\$addr\" -o -z \"\\\$bcast\" ] && return 1

if [ \"\\\$MODE\" = \"up\" ]
then
    /sbin/iptables -t nat -A PREROUTING -d \\\$addr -p udp --dport \\\$PORT -j DNAT --to-destination \\\$bcast
elif [ \"\\\$MODE\" = \"down\" ]
then
    /sbin/iptables -t nat -D PREROUTING -d \\\$addr -p udp --dport \\\$PORT -j DNAT --to-destination \\\$bcast
fi

exit 0
EOF
"

sudo chmod +x ${ROOTFS}/etc/network/if-down.d/222epicsbcast

###############################################################################
# fstab
###############################################################################

# Create .rw folders to mount as overlay
sudo mkdir -p ${ROOTFS}/var/lib/nfs.rw
sudo mkdir -p ${ROOTFS}/etc/docker.rw

# Setup Docker special folder as we are in a NFS, and some folders
# need to be RW and others needs to be RW, but overlayied with
# some previous configuration files (like /etc/docker)
sudo bash -c "cat << EOF > ${ROOTFS}/etc/fstab
proc                 /proc      proc    defaults   0 0
/dev/nfs             /          nfs     tcp,nolock 0 0
none                 /tmp       tmpfs   defaults   0 0
none                 /var/tmp   tmpfs   defaults   0 0
none                 /media     tmpfs   defaults   0 0
none                 /var/log   tmpfs   defaults   0 0
none                 /var/lib/dhcp   tmpfs   defaults   0 0
none                 /var/lib/nfs.rw   tmpfs   defaults   0 0
none                 /etc/docker.rw   tmpfs   defaults   0 0
none                 /var/lib/docker   tmpfs   defaults   0 0
EOF
"

###############################################################################
# Add mounting overlay services
###############################################################################

sudo bash -c "cat << EOF > ${ROOTFS}/etc/systemd/system/mount-docker-overlay.service
[Unit]
Description=Mount /etc/docker as an overlay filesystem
RequiresMountsFor=/etc/docker.rw
Before=docker.service
Requires=docker.service

[Service]
ExecStart=/bin/sh -c \" \\\\
    /bin/mkdir -p /etc/docker.rw/rw && \\\\
    /bin/mkdir -p /etc/docker.rw/workdir && \\\\
    /bin/mount -t overlay overlay \\\\
        -olowerdir=/etc/docker,upperdir=/etc/docker.rw/rw,workdir=/etc/docker.rw/workdir /etc/docker \\\\
\"

[Install]
WantedBy=multi-user.target
EOF
"

sudo chroot ${ROOTFS} systemctl enable mount-docker-overlay

sudo bash -c "cat << EOF > ${ROOTFS}/etc/systemd/system/mount-nfs-overlay.service
[Unit]
Description=Mount /var/lib/nfs as an overlay filesystem
RequiresMountsFor=/var/lib/nfs.rw
Before=docker.service
Requires=docker.service

[Service]
ExecStart=/bin/sh -c \" \\\\
    /bin/mkdir -p /var/lib/nfs.rw/rw && \\\\
    /bin/mkdir -p /var/lib/nfs.rw/workdir && \\\\
    /bin/mount -t overlay overlay \\\\
        -olowerdir=/var/lib/nfs,upperdir=/var/lib/nfs.rw/rw,workdir=/var/lib/nfs.rw/workdir /var/lib/nfs \\\\
\"

[Install]
WantedBy=multi-user.target
EOF
"

sudo chroot ${ROOTFS} systemctl enable mount-nfs-overlay

###############################################################################
# Add common folder for EPICS autosave
###############################################################################

sudo bash -c "cat << EOF > ${ROOTFS}/etc/systemd/system/mount-epics-autosave.service
[Unit]
Description=Mount/Create EPICS autosave filesystem
Before=docker.service
Requires=docker.service

[Service]
ExecStart=/bin/sh -c \" \\\\
    /bin/mkdir -p ${EPICSAUTOSAVE} \
\"

[Install]
WantedBy=multi-user.target
EOF
"

sudo chroot ${ROOTFS} systemctl enable mount-epics-autosave

###############################################################################
# Add bootstrap script for homes for NON containered apps
##############################################################################

sudo bash -c "cat << EOF > ${ROOTFS}/etc/systemd/system/boot-apps.service
[Unit]
Description=Bootstrap service to load non-containerized applications
After=autofs.service
Wants=autofs.service
ConditionPathExists=/home/server/boot-start-pre-apps.sh

[Service]
Type=oneshot
ExecStartPre=/home/server/boot-start-pre-apps.sh
ExecStart=/usr/local/bin/boot-apps/boot-start.sh /home/server
ExecStartPost=-/home/server/boot-start-post-apps.sh
ExecStopPre=-/home/server/boot-stop-pre-apps.sh
ExecStop=/usr/local/bin/boot-apps/boot-stop.sh /home/server
ExecStopPost=-/home/server/boot-stop-post-apps.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
"

sudo chroot ${ROOTFS} systemctl enable boot-apps

sudo mkdir -p ${ROOTFS}/usr/local/bin/boot-apps

# Add bootstrap start
sudo bash -c "cat << "EOF" > ${ROOTFS}/usr/local/bin/boot-apps/boot-start.sh
#!/usr/bin/env bash

SCRIPTPATH=\"\\\$( cd \"\\\$( dirname \"\\\${BASH_SOURCE[0]}\"  )\" && pwd  )\"
EXEC_SCRIPT_NAME=\"boot-start.sh\"

EXEC_FOLDER_RAW=\\\$1
# Remove repeated and trailing \"/\"
EXEC_FOLDER=\\\$(echo \\\${EXEC_FOLDER_RAW} | tr -s /); EXEC_FOLDER=\\\${EXEC_FOLDER%/}

# Execute home script if executable
if [ -x \\\${EXEC_FOLDER}/\\\${EXEC_SCRIPT_NAME} ]; then
    \\\${EXEC_FOLDER}/\\\${EXEC_SCRIPT_NAME}
fi
EOF
"

sudo chmod +x ${ROOTFS}/usr/local/bin/boot-apps/boot-start.sh

# Add bootstrap stop
sudo bash -c "cat << "EOF" > ${ROOTFS}/usr/local/bin/boot-apps/boot-stop.sh
#!/usr/bin/env bash

SCRIPTPATH=\"\\\$( cd \"\\\$( dirname \"\\\${BASH_SOURCE[0]}\"  )\" && pwd  )\"
EXEC_SCRIPT_NAME=\"boot-stop.sh\"

EXEC_FOLDER_RAW=\\\$1
# Remove repeated and trailing \"/\"
EXEC_FOLDER=\\\$(echo \\\${EXEC_FOLDER_RAW} | tr -s /); EXEC_FOLDER=\\\${EXEC_FOLDER%/}

# Execute home script if executable
if [ -x \\\${EXEC_FOLDER}/\\\${EXEC_SCRIPT_NAME} ]; then
    \\\${EXEC_FOLDER}/\\\${EXEC_SCRIPT_NAME}
fi
"

sudo chmod +x ${ROOTFS}/usr/local/bin/boot-apps/boot-stop.sh

###############################################################################
# Add bootstrap script for homes
###############################################################################

sudo bash -c "cat << EOF > ${ROOTFS}/etc/systemd/system/boot-container-apps.service
[Unit]
Description=Bootstrap service to load containerized applications
After=autofs.service
Requires=autofs.service
After=docker.service
Wants=docker.service
After=mount-docker-overlay.service
Requires=mount-docker-overlay.service
After=boot-apps.service
Wants=boot-apps.service
ConditionPathExists=/home/server/boot-start-pre-container-apps.sh

[Service]
Type=oneshot
ExecStartPre=/home/server/boot-start-pre-container-apps.sh
ExecStart=/usr/local/bin/boot-container-apps/boot-container-start.sh /home/server
ExecStartPost=-/home/server/boot-start-post-container-apps.sh
ExecStopPre=-/home/server/boot-stop-pre-container-apps.sh
ExecStop=/usr/local/bin/boot-container-apps/boot-container-stop.sh /home/server
ExecStopPost=-/home/server/boot-stop-post-container-apps.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
"

sudo chroot ${ROOTFS} systemctl enable boot-container-apps

sudo mkdir -p ${ROOTFS}/usr/local/bin/boot-container-apps

# Add bootstrap functions
sudo bash -c "cat << "EOF" > ${ROOTFS}/usr/local/bin/boot-container-apps/boot-functions.sh
#!/usr/bin/env bash

function get_compose_folders () {
    # Input arguments
    local EXEC_FOLDER_RAW=\\\$1

    # Local variables
    local EXEC_FOLDER=\\\$(echo \\\${EXEC_FOLDER_RAW} | tr -s /); EXEC_FOLDER=\\\${EXEC_FOLDER%/}
    # Get all docker-compose folders
    local COMPOSE_FOLDERS_REL=\\\$(find \\\${EXEC_FOLDER} -maxdepth 1 -type d -exec basename \"{}\" \; | \\\\
        grep -E \"^[0-9][0-9].*\" | sort)
    local COMPOSE_FOLDERS=()

    # Get add compose folders
    for cfolders in \\\${COMPOSE_FOLDERS_REL}; do
        COMPOSE_FOLDERS+=(\\\${EXEC_FOLDER}/\\\${cfolders})
    done

    echo \"\\\${COMPOSE_FOLDERS[@]}\"
}

function get_compose_files () {
    # Input arguments
    local COMPOSE_FOLDERS=\\\$1
    # Local variables
    local COMPOSE_FILES=()

    # Get all compose files
    for dir in \\\${COMPOSE_FOLDERS[@]}; do
        COMPOSE_FILES_RAW=(\\\$(ls \\\${dir} | grep -E \"^[0-9][0-9].*.(yml|yaml)\" | sort))
        for file in \\\${COMPOSE_FILES_RAW[@]}; do
            COMPOSE_FILES+=(\\\${dir}/\\\${file})
        done
    done

    echo \"\\\${COMPOSE_FILES[@]}\"
}
EOF
"

sudo chmod +x ${ROOTFS}/usr/local/bin/boot-container-apps/boot-functions.sh

# Add bootstrap start
sudo bash -c "cat << "EOF" > ${ROOTFS}/usr/local/bin/boot-container-apps/boot-container-start.sh
#!/usr/bin/env bash

SCRIPTPATH=\"\\\$( cd \"\\\$( dirname \"\\\${BASH_SOURCE[0]}\"  )\" && pwd  )\"

. \\\${SCRIPTPATH}/boot-functions.sh

EXEC_FOLDER_DIR=\\\$1
EXEC_FOLDERS=(\\\$(get_compose_folders \\\${EXEC_FOLDER_DIR}))

for dir in \\\${EXEC_FOLDERS[@]}; do
    COMPOSE_FILES=\\\$(get_compose_files \\\${dir})
    for file in \\\${COMPOSE_FILES[@]}; do
        bash -c \"cd \\\${dir} && \\\\
            docker-compose -f \\\${file} up -d\"
    done
done
EOF
"

sudo chmod +x ${ROOTFS}/usr/local/bin/boot-container-apps/boot-container-start.sh

# Add bootstrap stop
sudo bash -c "cat << "EOF" > ${ROOTFS}/usr/local/bin/boot-container-apps/boot-container-stop.sh
#!/usr/bin/env bash

SCRIPTPATH=\"\\\$( cd \"\\\$( dirname \"\\\${BASH_SOURCE[0]}\"  )\" && pwd  )\"

. \\\${SCRIPTPATH}/boot-functions.sh

EXEC_FOLDER_DIR=\\\$1
EXEC_FOLDERS=(\\\$(get_compose_folders \\\${EXEC_FOLDER_DIR}))

for dir in \\\${EXEC_FOLDERS[@]}; do
    COMPOSE_FILES=\\\$(get_compose_files \\\${dir})
    for file in \\\${COMPOSE_FILES[@]}; do
        bash -c \"cd \\\${dir} && \\\\
            docker-compose -f \\\${file} down\"
    done
done
EOF
"

sudo chmod +x ${ROOTFS}/usr/local/bin/boot-container-apps/boot-container-stop.sh

###############################################################################
# Add docker certificates
###############################################################################

# Clear hostname as this will be assigned from DHCP server
sudo bash -c "echo \"\" > ${ROOTFS}/etc/hostname"

# Copy certificate into correct location
sudo mkdir -p ${ROOTFS}/etc/docker/certs.d/dockerregistry.lnls-sirius.com.br:443
sudo cp foreign/docker-registry-certs/certs/domain.crt \
    ${ROOTFS}/etc/docker/certs.d/dockerregistry.lnls-sirius.com.br:443/ca.crt

sudo cp foreign/docker-registry-certs/certs/domain.crt \
    ${ROOTFS}/usr/local/share/ca-certificates/dockerregistry.lnls-sirius.com.br.crt
sudo chroot ${ROOTFS} update-ca-certificates

# After setting up everything unmount special filesystems
sudo bash -c "chroot ${ROOTFS} umount /proc || true"
