debian-rootfs
===============================

Overview
--------

This repository contains scripts to setup a complete rootfs based on
debian-9, docker and all of the necessary packages for a rootfs to be
used in a production environment.

This was designed to be used as a docker bind mount to the
NFS-server available here: https://github.com/lnls-sirius/docker-nfs-server

### Build rootfs/homes

    ./create-all.sh
