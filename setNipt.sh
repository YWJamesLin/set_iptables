#!/bin/bash
# Setting Normal iptables rules
# 2014.12.20 Created By YWJamesLin 2015.09.16 Last Modified

# Setting Variables
PATH="/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin"
OutIF="eth0"
PolPath="/usr/local/share/iptables"

# Initialize Kernel Configuration
for i in /proc/sys/net/ipv4/{tcp_syncookies,icmp_echo_ignore_broadcasts,conf/eth0/log_martians,ip_forward}; do
  echo "1" > ${i}
done
for j in /proc/sys/net/ipv4/conf/eth0/{accept_source_route,accept_redirects,send_redirects}; do
  echo "0" > ${j}
done

# Clean rules
iptables -F
iptables -X
iptables -Z

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# Filter Common policy
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Include other Policies
for i in ${PolPath}/{iptables.deny,iptables.allow,iptables.http}; do
  if [ -f ${i} ]; then 
    sh ${i}
  fi
done

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

#   WWW
#iptables -A INPUT -i ${OutIF} -p TCP --dport 80 --sport 1024:65534 -j ACCEPT

#   POP3
#iptables -A INPUT -i ${OutIF} -p TCP --dport 110 --sport 1024:65534 -j ACCEPT

#   SAMBA
#iptables -A INPUT -i ${OutIF} -p UDP --dport 137:138 --sport 1024:65534 -j ACCEPT
#iptables -A INPUT -i ${OutIF} -p TCP --dport 139:445 --sport 1024:65534 -j ACCEPT

#   NFS
#iptables -A INPUT -i ${OUTIF} -p TCP --dport 111 --sport 1024:65534 -j ACCEPT
#iptables -A INPUT -i ${OUTIF} -p UDP --dport 111:893 --sport 1024:65534 -j ACCEPT

#   HTTPS
#iptables -A INPUT -i ${OutIF} -p TCP --dport 443 --sport 1024:65534 -j ACCEPT

#   IPSec VPN
#iptables -A INPUT -i ${OutIF} -p esp -j ACCEPT
#iptables -A INPUT -i ${OutIF} -p ah -j ACCEPT
#iptables -A INPUT -i ${OutIF} -p udp --dport 500 --sport 1024:65534 -j ACCEPT
#iptables -A INPUT -i ${OutIF} -p udp --dport 4500 --sport 1024:65534 -j ACCEPT
#iptables -t nat -A POSTROUTING -o ${OutIF} -s 10.1.0.0/16 -j MASQUERADE

# Save Configuration
/etc/init.d/iptables save
