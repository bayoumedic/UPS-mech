#!/bin/bash
source /etc/cool.cfg


function mountACD(){
	local RESULT=0
	local DIRECTORY="$acd_mount"/z5RcIiqyW-DPa2MR-1L3z4tC
	if [ -d "$DIRECTORY" ]; then
		RESULT=1
	else	
		acd_cli clear-cache &>/dev/null
		acd_cli sync &>/dev/null
		acd_cli mount --modules="subdir,subdir=$amazon_subdirectory" "$acd_mount" &>/dev/null
		
		DIRECTORY2="$acd_mount"/z5RcIiqyW-DPa2MR-1L3z4tC
		if [ -d "$DIRECTORY2" ]; then
			RESULT=1
		fi
	fi
	echo $RESULT
}
function encACD(){
	local RESULT=0
	local DIRECTORY="$acd_decrypted"/Movies
	if [ -d "$DIRECTORY" ]; then
		RESULT=1
	else
		echo "$encfs_pass" | encfs -S "$acd_mount" "$acd_decrypted"  &>/dev/null 
		DIRECTORY="$acd_decrypted"/Movies

		if [ -d "$DIRECTORY" ]; then
			RESULT=1
		fi
	fi
	echo $RESULT
}
function encTRANS(){
	local RESULT=0
	local DIRECTORY="$transfer_decrypted"/Movies
	if [ -d "$DIRECTORY" ]; then
		RESULT=1
	else
		echo "$encfs_pass" | encfs -S "$transfer_encrypted" "$transfer_decrypted"  &>/dev/null
		DIRECTORY="$transfer_decrypted"/Movies
		if [ -d "$DIRECTORY" ]; then
			RESULT=1
		fi
	fi
	echo $RESULT
}
function repairACD(){
	fusermount -uz "$acd_decrypted" &>/dev/null
	fusermount -uz "$acd_mount" &>/dev/null
	fusermount -uz "$transfer_decrypted" &>/dev/null
	rm "$acd_mount"/.encfs6.xml &>/dev/null
	rm ~/.cache/acd_cli/nodes.db &>/dev/null
	acd_cli clear-cache &>/dev/null
	acd_cli sync &>/dev/null
}

echo "Mounting drives"
ACD=$(mountACD)
ENC=''


if [ $ACD -eq 0 ]; then
	echo "ACD failed to mount. Repairing now."
	repairACD
	echo "2nd attempt to mount acd"
	ACD=$(mountACD)
fi
if [ $ACD -eq 1 ]; then
	
	ENC=$(encACD)
else
	echo "unable to mount ACD"
	exit 1
fi

if [ $ENC -eq 0 ]; then
	echo "ENC failed to mount"
	exit 1
fi

TRANS=$(encTRANS)
if [ $TRANS -eq 0 ]; then
	echo "Failed to mount transfer"
fi

exit 0
