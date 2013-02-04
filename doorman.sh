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
avrdude_config="/etc/avrdude/avrdude.conf"
baudrate="115200"
hex_dir="hex"
ip="192.168.1.1"
macs_here="/tmp/macs_here"
port="/dev/ttyACM0"
programmer="stk500v1"
uri="Status_Wireless.asp"
username="HaruHaraHaruko"
userpass="TVPuppetPals!"

# array of mac addresses to monitor (does this really need to be an array?)
declare -a macs
macs=( AA:BB:CC:DD:EE:01 AA:BB:CC:DD:EE:02 )

# if the macs_here file doesn't exist, touch it
if [ ! -f "$macs_here" ]
then touch "$macs_here"
fi



# loop every 10 seconds
while :
do
  #

  macs_connected=$(curl -s --user $username:$userpass $ip/$uri | egrep ^setWirelessTable | sed s#\'#\\n#g | grep ":" | egrep "$(echo ${macs[@]} | tr ' ' '\|') | tr '\n' ';'")

  # if a MAC address is present, check if it's in the macs_here list. If not, unlock the door and add it!
  for ((i=0;i<${#macs[@]};i++))
  do if [ $(echo "$macs_connected" | grep "${macs["$i"]}" | wc -l) -eq 1  ]  # if the mac address is present in the router log,
     then  if [ $(grep ${macs["$i"]} "$macs_here" | wc -l) -eq 0 ]  # and the mac address is not present in the file log,
           then # unlock and add the mac address
#                "$AVRDUDE" -C "$avrdude_config" -F -p "$arduino_type" -c "$programmer" -P "$port" -b "$baudrate" -D -Uflash:w:"$hex"/clockwise_lock.cpp.hex
                "$AVRDUDE" -C "$avrdude_config" -F -p "$arduino_type" -c "$programmer" -P "$port" -b "$baudrate" -D -Uflash:w:"$hex_dir"/counterclockwise_unlock.cpp.hex
                echo ${macs["$i"]} >> "$macs_here"            
           fi
     else  if [ $(grep ${macs["$i"]} "$macs_here" | wc -l) -eq 1 ]  # if the mac is not present in the router logs, but the mac is present in the file log
     	   then # lock and remove the mac address
                "$AVRDUDE" -C "$avrdude_config" -F -p "$arduino_type" -c "$programmer" -P "$port" -b "$baudrate" -D -Uflash:w:"$hex_dir"/clockwise_lock.cpp.hex
     	        sed -i $(grep -n ${macs["$i"]} "$macs_here" | tr ':' '\n' | head -1)d "$macs_here"
     	   fi
  	 fi
  done
  sleep 10
done
