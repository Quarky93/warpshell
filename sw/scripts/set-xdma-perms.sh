#!/bin/bash
#
# Correct access permissions of character devices of the xdma driver
#

if [ "$EUID" -ne 0 ]; then
   echo "This script must be run as root"
   exit 1
fi

chown root:dialout /dev/xdma*
chmod 220 /dev/xdma*_h2c_*
chmod 440 /dev/xdma*_c2h_*
chmod 660 /dev/xdma*_user
