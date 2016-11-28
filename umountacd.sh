#!/bin/bash
source /etc/cool.cfg

ps cax | grep "Plex Media Scan" > /dev/null
if [ $? -eq 0 ]; then
  echo "Plex is currently scanning. Can not unmount"
else
	fusermount -uz "$acd_decrypted" 2>/dev/null 
	DIRECTORY="$acd_decrypted"/Movies
	if [ -d "$DIRECTORY" ]; then
		echo "ENC Failed to dismount"
	else
		fusermount -uz "$acd_mount" 2>/dev/null
		DIRECTORY="$acd_mount"/z5RcIiqyW-DPa2MR-1L3z4tC
		if [ -d "$DIRECTORY" ]; then
			echo "ACD failed to dismount"
		fi
	fi
	rm "$acd_mount"/.encfs6.xml  2>/dev/null
fi
