set -euxo pipefail

# User modifiable
DEBIAN_URL="http://ftp.us.debian.org/debian"
DEBIAN_FLAVOR=stretch
ROOTFSREL=rootfs
GENERIC_USER=server
ROOTFS_IP="192.168.2.12"

# Flavored variables
EXPORTDIR=exports
TOPDIR=${SCRIPTPATH}/${EXPORTDIR}
ROOTFS=${TOPDIR}/${ROOTFSREL}
