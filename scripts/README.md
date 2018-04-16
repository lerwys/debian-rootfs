Host scripts
===============================

Overview
--------

This scripts are to be run on a host serving the NFS image, that MIGHT
be used as a router between an internal isolated LAN and a LAN.

On the isolated LAN, remember to set the gateway to the Host's IP!

If the gateway (IP of the Host) is 192.168.2.12 and the default gateway
is 192.168.2.1, do the following:

    ```bash
    ip route del default via 192.168.2.1
    ip route add default via 192.168.2.12
    ```
