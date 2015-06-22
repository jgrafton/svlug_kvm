#!/bin/bash

# usage
if [ -z $1 ]; then
  echo "create_bridge creates a local ethernet bridge for a KVM hypervisor."
  echo "Requires a NetworkManager based system (>= CentOS 7.x or Ubuntu 15.x)"
  echo " "
  echo "SYNTAX:  create_bridge.sh interface"
  echo " "
  echo "interface   The ethernet interface you would like to use for the"
  echo "            host bridge.  If you're unsure which ethernet interface"
  echo "            you'd like to use, set interface to auto."
  exit 1
fi

# does this system support NetworkManager?
NMCLI=`which nmcli`
if [ -z $NMCLI ]; then
  echo "NetworkManager not detected on this system.  Exiting."
  exit 1
fi

# is NetworkManager connected?
RESULT=`$NMCLI -t -f state general status`
if [[ $RESULT != 'connected' ]]; then
  echo "Network manager state is not connected."
  exit 1
fi

# find the ethernet interface
if [ $1 == "auto" ]; then
  ETHERNET_INTERFACE=`nmcli -t -f name con show --active | grep "^e" | head -1`
  echo "Detected ethernet interface ${ETHERNET_INTERFACE}."
else
  ETHERNET_INTERFACE=$1
fi

# is a bridge already setup on this system?
RESULT=`$NMCLI -t -f name con show --active | grep "^b" | head -1`
if [ -z $RESULT ]; then
  echo "No bridges found."
else
  echo "bridge found:  $RESULT, exiting"
  exit 1
fi

# save state of the selected ethernet device
IPV4_METHOD=`nmcli -t -f ipv4.method con show $ETHERNET_INTERFACE | awk -F: '{ print $2 }'`
IPV4_ADDRESS=`nmcli -t -f ipv4.addresses con show $ETHERNET_INTERFACE | awk -F: '{ print $2 }'`
IPV4_GATEWAY=`nmcli -t -f ipv4.gateway con show $ETHERNET_INTERFACE | awk -F: '{ print $2 }'`
IPV4_DNS=`nmcli -t -f ipv4.dns con show $ETHERNET_INTERFACE | awk -F: '{ print $2 }'`

if [ -z $ETHERNET_INTERFACE ]; then
  echo "Cannot auto detect ethernet device!"
  exit 1
fi

if [ -z $IPV4_METHOD ]; then
  echo "ipv4.method is blank!  exiting."
  exit 1
fi

# if not DHCP, then make sure all values are filled in
if [[ "$IPV4_METHOD" != "auto" ]]; then

  if [ -z $IPV4_ADDRESS ]; then
    echo "ipv4.address is blank!  exiting."
    exit 1
  fi

  if [ -z $IPV4_GATEWAY ]; then
    echo "ipv4.gateway is blank!  exiting."
    exit 1
  fi

  if [ -z $IPV4_DNS ]; then
    echo "ipv4.dns is blank!  exiting."
    exit 1
  fi

fi

# remove default ethernet profile and add bridge
$NMCLI con del $ETHERNET_INTERFACE

# add bridge
$NMCLI con add type bridge con-name bridge0 ifname br0 
$NMCLI con add type bridge-slave ifname $ETHERNET_INTERFACE master bridge0 

# using a static IP address
if [[ "$IPV4_METHOD" != "auto" ]]; then
  $NMCLI con mod bridge0 ipv4.method manual ipv4.address $IPV4_ADDRESS ipv4.gateway $IPV4_GATEWAY ipv4.dns $IPV4_DNS
  $NMCLI con down bridge0
  $NMCLI con down "bridge-slave-${ETHERNET_INTERFACE}"
  $NMCLI con up "bridge-slave-${ETHERNET_INTERFACE}"
  $NMCLI con up bridge0
fi

echo "Bridge creation complete."
