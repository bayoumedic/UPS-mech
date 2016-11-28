#!/bin/bash

source my.conf
 ~/UPS-mech/mountacd.sh
 
UPDATE_NEEDED_M=0
UPDATE_NEEDED_T=0
while :
do
	CKM=0
	CKT=0
	echo "-----------------------------------"
	echo "-----------scanning tv-------------"
	FILES="$incoming_media"/TV/* 
	for SHOW_P in $FILES/; do
	  SHOW=$(basename "$SHOW_P")
	  if [ ! "$SHOW" = "*" ]; then
		for SEASON_P in "$SHOW_P"*/; do
		  SEASON=$(basename "$SEASON_P")
		  if [ ! "$SEASON" = "*" ]; then
			for EPISODE_P in "$SEASON_P"/*; do
			  EPISODE=$(basename "$EPISODE_P")
			  if [ ! "$EPISODE" = "*" ]; then
			  	MFILE_EXTENSION="${EPISODE##*.}"
				MFILE_NAME="${EPISODE%.*}"
				echo  $EPISODE
			  	if [ "$MFILE_EXTENSION" = "mp4" ] || [ "$MFILE_EXTENSION" = "mkv" ] || [ "$MFILE_EXTENSION" = "avi" ]; then
					echo "[Converting]"
					python ~/sickbeard_mp4_automator/manual.py -i "$EPISODE_P" -a  &>/dev/null
					echo "[Encrypting]"
					mkdir "$transfer_decrypted"/TV/"$SHOW" 2> /dev/null
					mkdir "$transfer_decrypted"/TV/"$SHOW"/"$SEASON" 2> /dev/null
					mv "$incoming_media"/TV/"$SHOW"/"$SEASON"/"$MFILE_NAME".mp4 "$transfer_decrypted"/TV/"$SHOW"/"$SEASON"/"$MFILE_NAME".mp4
					CKT=1
				fi
			  fi
			done
		  fi
		done
	  fi
	done
	
	echo "---------scanning movies-----------"
	FILES="$incoming_media"/Movies/* 
	for MOVIES_P in $FILES/; do
		MOVIE=$(basename "$MOVIES_P")
		if [ ! "$MOVIE" = "*" ]; then
			echo "$MOVIE"
			MFILES_P="$incoming_media"/Movies/"$MOVIE"
			rm "$incoming_media"/Movies/"$MOVIE"/RARBG.COM.mp4 2< /dev/null
			for MFILE in "$MFILES_P"/*; do
				MFILE_BASE=$(basename "$MFILE")
				MFILE_EXTENSION="${MFILE_BASE##*.}"
				MFILE_NAME="${MFILE_BASE%.*}"
				if [ "$MFILE_EXTENSION" = "mp4" ] || [ "$MFILE_EXTENSION" = "mkv" ] || [ "$MFILE_EXTENSION" = "avi" ]; then
					echo "[Converting]"
					python ~/sickbeard_mp4_automator/manual.py -i "$incoming_media"/Movies/"$MOVIE"/ -a  &>/dev/null
				fi
			done
			for MFILE in "$MFILES_P"/*; do
				ACD_DIR="$acd_decrypted"/Movies/"$MOVIE"
				MFILE_BASE=$(basename "$MFILE")
				MFILE_EXTENSION="${MFILE_BASE##*.}"
				MFILE_NAME="${MFILE_BASE%.*}"
				if [ "$MFILE_EXTENSION" = "mp4" ] || [ "$MFILE_EXTENSION" = "mkv" ] || [ "$MFILE_EXTENSION" = "avi" ]; then
					echo "[Encrypting]"
					mv "$incoming_media"/Movies/"$MOVIE"/"$MOVIE_BASE" "$transfer_decrypted"/
					CKM=1
				fi
			done
		fi
	done
  if [ $CKM -eq 1 ]; then
		UPDATE_NEEDED_M=1
	fi
	if [ $CKT -eq 1 ]; then
		UPDATE_NEEDED_T=1
	fi 
  
  if [ $UPDATE_NEEDED_M -eq 1 ] || [ $UPDATE_NEEDED_T -eq 1 ]; then
	  echo "------------syncing----------------"
	  rclone move "$transfer_encrypted" acd:Videos/edrive
	  find "$transfer_decrypted"/TV -type d -empty -delete
	  find "$transfer_decrypted"/Movies -type d -empty -delete
	  mkdir "$transfer_decrypted"/TV  2> /dev/null
	  echo "-----------------------------------"
  fi
	
	

	ps cax | grep "Plex Media Scan" > /dev/null
  if [ $? -eq 0 ]; then
    echo "---------UPDATE DELAYED------------"
  else
		if [ $CKT -eq 1 ] || [ $CKM -eq 1 ]; then
			~/UPS_mech/umountacd.sh
      ~/UPS_mech/mountacd.sh
		fi
		if [ $UPDATE_NEEDED_M -eq 1 ]; then
			wget -q -O- "$plex_movies_refresh"
			UPDATE_NEEDED_M=0
			echo "---------UPDATING MOVIES-----------"
		fi
		if [ $UPDATE_NEEDED_T -eq 1 ]; then
			wget -q -O- "$plex_tv_refresh"
			UPDATE_NEEDED_T=0
			echo "-----------UPDATING tv-------------"
		fi
	fi
	echo "-----------------------------------"
	sleep "&sleep_time"
done
