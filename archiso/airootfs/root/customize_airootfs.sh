systemctl set-default graphical.target

systemctl enable sddm.service
systemctl enable NetworkManager.service

## Sudoers File Configuration
mkdir -p /etc/sudoers.d

cat <<EOF > /etc/sudoers.d/10-wheel-nopass
# Allow arhiso user to use sudo with password
%wheel ALL=(ALL) ALL
EOF

chmod 440 /etc/sudoers.d/10-wheel-nopasswd

## Create User
useradd -m -u 1000 -G wheel,video,storage,optical -s /bin/bash archlive
groupadd archlive
passwd -d archlive
cp -r /etc/skel/. /home/archlive
chown -R archlive:archlive /home/archlive

## yay helper install
sudo -u archlive bash<<'EOF'
set -e
rm -rf yay
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay 
makepkg -fsir --noconfirm --needed
sudo mv yay /usr/local/bin/yay
chmod 755 /usr/local/bin/yay
cd /
rm -rf /tmp/yay

yay --version
EOF

## calamares install
pacman -Sy --noconfirm
yay -S --noconfirm calamares

## Cleaning Process
pacman -Sc --noconfirm