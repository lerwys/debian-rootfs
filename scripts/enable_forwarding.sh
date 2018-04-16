#!/usr/bin/env bash

# The intent of this script is to be used at TESTING environment.
# The network topology is assumed to be as following:
#
# Isolated LAN (192.168.2.0/24) <---> Switch (192.168.2.10/24) <--->
#     <---> (enp5s0) (192.168.2.12/24) Linux Box (eth2) (10.0.18.x/24) <---> LAN
#
# The idea is to redirect all traffic from internal LAN to LAN thjrough the Linux Box.
# This can be done by setting the following.
#
# REMEMBER! On the isolated LAN, remember to set the gateway to the Host's IP!
#
#If the gateway (IP of the Host) is 192.168.2.12 and the default gateway
#is 192.168.2.1, do the following:
#
#    ip route del default via 192.168.2.1
#    ip route add default via 192.168.2.12

set -euxo pipefail

# eth2 is internet
# enp5s0 is LAN

# Enable forwarding
sysctl -w net.ipv4.ip_forward=1

# masquarade all outgoing IPs to the one set by eth2
sudo iptables -A POSTROUTING -t nat -o eth2 -j MASQUERADE
# Accept/Forward connections from LAN if they are already established from internal LAN
sudo iptables -A FORWARD -i eth2 -o enp5s0 -m state --state ESTABLISHED,RELATED -j ACCEPT
# Accept/Forward all outgoing internal LAN connections
sudo iptables -A FORWARD -i enp5s0 -o eth2 -j ACCEPT
