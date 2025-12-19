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

## Install Packages
pacman -U --noconfirm /root/packages/*.pkg.tar.zst