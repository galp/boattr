#!bin/bash
iptables -t nat -F
iptables -F
echo 1 > /proc/sys/net/ipv4/ip_forward

if [ -z "$1" ] ; then
    LAN='br0'
    WAN='usb0'
else 
    LAN=$1
    WAN=$2
fi
iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE
iptables -A FORWARD -i $WAN -o $LAN -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $LAN -o $WAN -j ACCEPT

ip route del default
dhclient $WAN
