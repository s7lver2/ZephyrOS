directory=/home/$USER/ZephyrOS/work
output=/home/$USER/ZephyrOS/out

sudo rm -rf $directory

sudo mkarchiso -v -w $directory -o $output archiso