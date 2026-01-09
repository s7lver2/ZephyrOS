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

# Calamares
cp -r /usr/local/lib/calamares-libs/* /usr/lib/

chmod +x /usr/local/bin/*

## sddm config
mkdir -p /usr/share/sddm/themes
cp -r /usr/local/share/zephyr-theme/eucalyptus-drop /usr/share/sddm/themes/

## kde config
# cp -r /usr/local/share/zephyr-theme/.local/ /etc/skel/.local
cp /usr/local/share/zephyr-theme/kdeglobals /etc/skel/.config/

## Create User
useradd -m -u 1000 -G wheel,video,storage,optical -s /bin/bash archlive
groupadd archlive
passwd -d archlive
cp -r /etc/skel/. /home/archlive
chown -R archlive:archlive /home/archlive