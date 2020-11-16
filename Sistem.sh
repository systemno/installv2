#!/bin/sh

apt-get update && apt-get -y upgrade

apt-get install tor iptables-persistent

wget http://swupdate.openvpn.org/as/openvpn-as-2.1.4-Ubuntu14.amd_64.deb
dpkg -i openvpn-as-2.1.4-Ubuntu14.amd_64.deb

passwd openvpn

cat >> /etc/tor/torrc <<EOF
VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
TransListenAddress 172.27.232.1
DNSPort 53
DNSListenAddress 172.27.232.1
EOF

cat > ~/iptables.sh <<EOF
#!/bin/sh

# Tor's TransPort
_trans_port="9040"

# your internal interface
_int_if="as0t1"

iptables -F
iptables -t nat -F

iptables -t nat -A PREROUTING -i $_int_if -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i $_int_if -p tcp --syn -j REDIRECT --to-ports $_trans_port
EOF

/bin/sh ~/iptables.sh 

update-rc.d -f tor remove
update-rc.d tor defaults 99

update-rc.d -f iptables-persistent
update-rc.d iptables-persistent defaults 99

