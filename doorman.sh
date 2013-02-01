#!/bin/bash
#===============================================================================
#
#          FILE: doorman.sh
# 
#         USAGE: set a cron job to ensure ./doorman.sh is running
# 
#   DESCRIPTION: Lock/unlock door based on 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: Tested with a Netgear dd-wrt'd router with mini firmware rev.24
#                0.2 (FUTURE) unlock/lock based on time of day so it's easier to
#                    leave the house at 6:50 every morning and have the door
#                    lock at 7:00.
#                0.3 avrdude is the program of choice.
#
#  ORGANIZATION: ---
#       CREATED: 27 January 2013
#      REVISION: 0.1 Base functionality for unlocking when a new address appears
#                    need to update to use script rather than IDE. Need to add 
#                    touch file so it doesn't keep unlocking once a mac connects
#===============================================================================

# user-defined variables
AVRDUDE="/bin/avrdude"
arduino_type="m328p"
avrdude_config="/etc/avrdude/avrdude.conv"
baudrate="115200"
hex_dir="hex"
ip="192.168.1.1"
mac_allow="/usr/local/etc/mac_allow"
port="/dev/ttyACM0"
programmer="stk500v1"
uri="Status_Wireless.asp"
username="HaruHaraHaruko"
userpass="TVPuppetPals!"

# array of mac addresses to monitor (does this really need to be an array?)
declare -a macs
macs=( AA:BB:CC:DD:EE:01 AA:BB:CC:DD:EE:02 )

# loop every 10 seconds
while :
do
  # since we don't care who corresponds to what mac address (at the moment), unlock whenever a new address is present
  if [ $(curl --user $user:$pass $ip/$uri | egrep ^setWirelessTable | tr \' '\n' | grep ":" | egrep "$(echo ${#macs[@]} | tr ' ' '\|')" | wc -l) -le $(wc -l $mac_allow)]
  then  "
        "$AVRDUDE" -C "$avrdude_config" -F -p "$arduino_type" -c "$programmer" -P "$port" -b "$baudrate" -D -Uflash:w:"$hex"/counterclockwise_unlock.cpp.hex
  fi
  
  sleep 10
done
