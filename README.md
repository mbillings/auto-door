auto-door
=========

###What does this do?
Monitors MAC addresses on your router's DD-WRT, signals servo appropriately (lock/unlock).

-----------------------------------
###About the included c++ ino files
These are modified versions of the sample arduino servo "sweep" program, which have been modified to rotate a continuous servo 160 degrees.

-------------------------------
###About the included hex files
These have been compiled on arduino v1.0.1 release 1.fc17. This is purely information and should not need to be adjusted.

--------
###Notes
If you need to modify the c++ code for a non-continuous servo, use the arduino IDE instead. Trying to use the (unsupported) makefiles is an exercise in futility.

Make sure the IDE is in debug mode so you can see where it writes the hex, usually to /tmp

