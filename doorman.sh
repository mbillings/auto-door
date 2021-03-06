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
#                - (FUTURE) unlock/lock based on time of day so it's easier to
#                  leave the house at 6:50 every morning and have the door
#                  lock at 7:00.
#                - avrdude is the program of choice for uploading hex files.
#                - Recompiled hex files so lock resets to position 179,
#                  but since there is no set position for unlock to fully
#                  unlock the deadbolt, we set it to just move a certain amount
#                  until the door is unlocked.
#                  Because of this, we always reset to the locked position 
#                  before unlocking.
#                  This was done because we still want to be able to manually
#                  lock/unlock the deadbolt if we're inside our house without
#                  having to turn off/on our phone's wifi.
#
#  ORGANIZATION: ---
#       CREATED: 27 January 2013
#      REVISION: 0.1 Base functionality for unlocking when a new address appears
#                    need to update to use script rather than IDE. Need to add 
#                    touch file so it doesn't keep unlocking once a mac connects
#===============================================================================

# ardunio and transfer layer variables
AVRDUDE="/bin/avrdude"
arduino_type="m328p"
avrdude_config="/etc/avrdude/avrdude.conf"
baudrate="115200"
port="/dev/ttyACM0"
programmer="stk500v1"

# router variables
ip="192.168.1.1"
uri="Status_Wireless.asp"
username="HaruHaraHaruko"
userpass="TVPuppetPals!"

# OS variables
hex_dir="/home/me/auto-door/hex"
macs_here="/tmp/macs_here"
poll_interval="5"
reset_lock="reset_lock.cpp.hex"
unlock="ccw_unlock.cpp.hex"

# array of mac addresses to monitor (does this really need to be an array?)
declare -a macs
macs=( AA:BB:CC:DD:EE:01 AA:BB:CC:DD:EE:02 )





# since we just started up, let's reset to the set locked position so we can lock/unlock and reset macs_here file
"$AVRDUDE" -C "$avrdude_config" -F -p "$arduino_type" -c "$programmer" -P "$port" -b "$baudrate" -D -Uflash:w:"$hex_dir"/"$reset_lock"
echo "closed $(date --date="now" +%s)" > "$macs_here"  # put "closed" in the FILE log to change the status to unlocked


# loop 
while :
do
  # get the current macs connected from the router page
  macs_connected=$(curl -s --user $username:$userpass $ip/$uri | egrep ^setWirelessTable | sed s#\'#\\n#g | grep ":" | egrep "$(echo ${macs[@]} | tr ' ' '\|') | tr '\n' ';'")

# this will be consolidated into one if/then statement after initial testing

  # MACs if a MAC address is present, check if it's in the macs_here list. If not, unlock the door and add it!
  for ((i=0;i<${#macs[@]};i++))
  do if [ $(echo "$macs_connected" | grep "${macs["$i"]}" | wc -l) -eq 1  ]  # if the mac address IS present in the ROUTER log,
     then if [ $(grep ${macs["$i"]} "$macs_here" | wc -l) -eq 0 ]           # and the mac address is NOT present in the FILE log,
          then                                                              
               echo ${macs["$i"]} >> "$macs_here"                           # add the mac address to the FILE log

               status=$(grep "closed" "$macs_here" | wc -l)                 # check and see if the lock is currently in the closed position
               if [ "$status" -eq 1 ]                                       # if it is locked,
               then                                                         # send the hex files to the servo to reset its position, and unlock
                    "$AVRDUDE" -C "$avrdude_config" -F -p "$arduino_type" -c "$programmer" -P "$port" -b "$baudrate" -D -Uflash:w:"$hex_dir"/"$reset_lock"
                    "$AVRDUDE" -C "$avrdude_config" -F -p "$arduino_type" -c "$programmer" -P "$port" -b "$baudrate" -D -Uflash:w:"$hex_dir"/"$unlock"
                     sed -i '/closed/d' "$macs_here"                        # delete the line containing "closed"
                     echo "open $(date --date="now" +%s)" >> "$macs_here"   # put "open" in the FILE log to change the status to unlocked
               fi
          fi
     else if [ $(grep ${macs["$i"]} "$macs_here" | wc -l) -eq 1 ]           # if the mac is NOT present in the ROUTER logs, but the mac IS present in the FILE log
     	  then 
     	       mac=`echo ${macs["$i"]}`
     	       sed -i /$mac/d "$macs_here"                                  # delete the mac address from the FILE log
     	       #sed -i $(grep -n ${macs["$i"]} "$macs_here" | tr ':' '\n' | head -1)d "$macs_here" # delete the mac address from FILE log
     	       
     	       status=$(grep "open" "$macs_here" | wc -l)                   # check if we are open (unlocked) 
               if [ "$status" -eq 1 ]                                       # if we are open (unlocked)
               then                                                         # send the reset_lock hex file to the arduino to lock it
                    "$AVRDUDE" -C "$avrdude_config" -F -p "$arduino_type" -c "$programmer" -P "$port" -b "$baudrate" -D -Uflash:w:"$hex_dir"/"$reset_lock"
                    sed -i '/open/d' "$macs_here"                           # delete the line containing "open"
                    echo "closed $(date --date="now" +%s)" >> "$macs_here"  # put "closed" in the FILE log to change the status to unlocked
     	       fi
     	  fi
  	 fi
  done
  sleep $poll_interval
done
