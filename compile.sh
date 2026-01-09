output=/home/s7lver/ZephyrOS/output
work=/home/s7lver/ZephyrOS/work

sudo pacman -S yaml-cpp extra-cmake-modules
 
sudo rm -rf work

sudo mkarchiso -v -w work -o out archiso