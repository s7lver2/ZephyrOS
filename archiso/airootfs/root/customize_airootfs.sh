systemctl set-default graphical.target

systemctl enable sddm.service
systemctl enable NetworkManager.service


## Create User
useradd -m -u 1000 -G wheel,video,storage,optical -s /bin/bash archlive
groupadd archlive
passwd -d archlive
cp -r /etc/skel/. /home/archlive
chown -R archlive:archlive /home/archlive