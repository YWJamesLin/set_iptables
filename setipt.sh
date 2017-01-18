#!/bin/bash
# Setting iptables rules
# Debugging Mode is to apply ACCEPT policy on Filter-INPUT chain
# 2014.12.20 Created By YWJamesLin

# Setting Variables
PATH="/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin:/usr/local/bin"
OutIF="eth0"

#0 with Input Accept as default, 1 with Input Drop as default
Mode="${1}"

# Mode Checking
if [ ${Mode} != 0 ] && [ ${Mode} != 1 ];then
  read -p "Installing in which mode?(0:Normal 1:Debugging)" Mode
fi

# Initialize Kernel Configuration
for i in /proc/sys/net/ipv4/{tcp_syncookies,icmp_echo_ignore_broadcasts,conf/${OutIF}/log_martians,ip_forward}; do
  echo "1" > ${i}
done

for j in /proc/sys/net/ipv4/conf/${OutIF}/{accept_source_route,accept_redirects,send_redirects}; do
  echo "0" > ${j}
done

# Clean rules
iptables -F
iptables -X
iptables -Z

# Default Policy
if [ ${Mode} == 0 ]; then
  iptables -P INPUT DROP
else
  iptables -P INPUT ACCEPT
fi
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# Filter Common policy
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Accept some ICMP packets
AICMP="0 3 4 11 12 14 16 18"
for ICMPN in ${AICMP}; do
  iptables -A INPUT -i ${OutIF} -p icmp --icmp-type ${ICMPN} -j ACCEPT
done

# Accept access to some Services(Daemons)

#   FTP
#iptables -A INPUT -i ${OutIF} -p TCP --dport 21 --sport 1024:65534 -j ACCEPT

#   SSH
#iptables -A INPUT -i ${OutIF} -p TCP --dport 22 --sport 1024:65534 -j ACCEPT

#   SMTP
#iptables -A INPUT -i ${OutIF} -p TCP --dport 25 --sport 1024:65534 -j ACCEPT

#   DNS
#iptables -A INPUT -i ${OutIF} -p TCP --dport 53 --sport 1024:65534 -j ACCEPT
#iptables -A INPUT -i ${OutIF} -p UDP --dport 53 --sport 1024:65534 -j ACCEPT

#   HTTP
#iptables -A INPUT -i ${OutIF} -p TCP --dport 80 --sport 1024:65534 -j ACCEPT

#   POP3
#iptables -A INPUT -i ${OutIF} -p TCP --dport 110 --sport 1024:65534 -j ACCEPT

#   SAMBA
#iptables -A INPUT -i ${OutIF} -p TCP --dport 139 --sport 1024:65534 -j ACCEPT
#iptables -A INPUT -i ${OutIF} -p TCP --dport 445 --sport 1024:65534 -j ACCEPT
#iptables -A INPUT -i ${OutIF} -p UDP --dport 137 --sport 1024:65534 -j ACCEPT
#iptables -A INPUT -i ${OutIF} -p UDP --dport 138 --sport 1024:65534 -j ACCEPT

#   NFS
#iptables -A INPUT -i ${OutIF} -p TCP --dport 111 --sport 1024:65534 -j ACCEPT
#iptables -A INPUT -i ${OutIF} -p UDP --dport 111 --sport 1024:65534 -j ACCEPT
#iptables -A INPUT -i ${OutIF} -p UDP --dport 893 --sport 1024:65534 -j ACCEPT

#   HTTPS
#iptables -A INPUT -i ${OutIF} -p TCP --dport 443 --sport 1024:65534 -j ACCEPT

#   IPSec VPN
#iptables -A INPUT -p ESP -j ACCEPT
#iptables -A INPUT -p AH -j ACCEPT
#iptables -A INPUT -p UDP --dport 500 -j ACCEPT
#iptables -A INPUT -p UDP --dport 4500 -j ACCEPT

#   OpenVPN VPN
#iptables -A INPUT -i ${OutIF} -p UDP --dport 1194 --sport 1024:65534 -j ACCEPT

#   MASQUERADE
#iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -m policy --dir out --pol ipsec -j ACCEPT
#iptables -t nat -A POSTROUTING -o ${OutIF} -s 10.0.0.0/8 -j MASQUERADE
