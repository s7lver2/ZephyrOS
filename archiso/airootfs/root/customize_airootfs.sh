systemctl set-default graphical.target

systemctl enable sddm.service
systemctl enable NetworkManager.service


## Create User
useradd -m -u 1000 -G wheel,video,storage,optical -s /bin/bash archlive
groupadd archlive
passwd -d archlive
cp -r /etc/skel/. /home/archlive
chown -R archlive:archlive /home/archlive

## yay helper install
sudo -u archlive <<'EOF'
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay 
makepkg -si --noconfirm
rm -rf /tmp/yay
EOF

## calamares install
pacman -Sy --noconfirm
yay -S --noconfirm calamares

## Cleaning Process
pacman -Sc --noconfirm