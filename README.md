# UPS-mech
Program to process incoming movies and tv shows for use in the unlimited plex server setup.  (Amazon Cloud Drive with ENCFS encryption)
This will cycle through your new media downloads, convert them to mp4, upload to amazon cloud drive then update your plex library

<b>Requirements:</b>
Amazon Cloud Drive account https://www.amazon.com/clouddrive/home
ACD_CLI https://github.com/yadayada/acd_cli/blob/master/docs/setup.rst
ENCFS https://www.howtoforge.com/tutorial/encrypt-your-data-with-encfs-on-ubuntu/
rclone http://rclone.org/install/
sickbeard_mp4_automator https://github.com/mdhiggins/sickbeard_mp4_automator

<b>Updating the my.conf file:</b>
encfs_pass: save your password encfs password here
amazon_subdirectory: directory in amazon cloud drive to save all your media to
sleep_time:  time between scans

<b>plex_movies_refresh and plex_tv_refresh</b>
  refresh urls to use
  http://[location]:[port]/library/sections/[library id]/refresh?X-Plex-Token=[token]
    The library id can be found by opening plex server in your browser then opening the library (Movies or TV)
    You will see something like this server/1963a31a289d3e6536e6510ed75e2f776c272bfb/section/2/all in the url
    In this case the id is 2
    
    The token can be found by clicking on a movie or tv show >> info >> viewxml
    The token will be in the url

Create the encrypted mount folder for amazon cloud
  mkdir ~/UPS-mech/.media 
  All of these folder locations can be customized in my.conf
  
Create the decrypted mount folder for amazon cloud
  mkdir ~/UPS-mech/media
  
<b>----If this is your first time setting up the encrypted and decrypted folders----</b>
mount acd to ~/UPS-mech/.media
  acd_cli mount --modules="subdir,subdir=/Videos" /home/user/UPS-mech/.media  
    change subdir and user to your own
    must use full path names (not ~/UPS-mech/.media)
mount the decrypted drive
  encfs /home/user/UPS-mech/.media /home/user/UPS-mech/media
    must use full path names
<b>-----</b>
Change the user in the paths in the my.conf file to your own

copy the encfs file for backup
  cd ~/UPS-mech/.media
  cp .encfs6.xml ~/UPS-mech
  
create these folders 
  mkdir ~/UPS-mech/incoming/TV
  mkdir ~/UPS-mech/incoming/Movies
  
<b>using with Sonarr / Sickbeard</b>
have these programs run first.
point tv show downloads to be saved to ~/UPS-mech/incoming/TV
and movies to ~/UPS-mech/incoming/Movies
UPS-mech will watch these locations

<b>USAGE</b>
run process.sh 



