#!/bin/bash



echo blackbird > /etc/hostname

ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

hwclock --systohc 

timedatectl set-ntp true

printf "en_US.UTF-8 UTF-8\nen_US ISO-8859-1" >> /etc/locale.gen

locale-gen && locale > /etc/locale.conf

sed -i '1s/.*/'LANG=en_US.UTF-8'/' /etc/locale.conf

echo 'EDITOR="/usr/bin/nvim"' >> /etc/environment



### ADMINISTRATOR

useradd -m sysadmin

chown -R sysadmin:sysadmin /home/lektor

echo 'sysadmin ALL=(ALL:ALL) ALL' > /etc/sudoers.d/00_sysadmin

passwd sysadmin

mkdir /opt/cockpit

useradd -d /opt/cockpit nepster

usermod -a -G wheel nepster


su sysadmin

git clone https://aur.archlinux.org/mkinitcpio-clevis-hook /tmp/clevis

makepkg -sric --dir /tmp/clevis --noconfirm

gpg --recv-keys 2BBBD30FAAB29B3253BCFBA6F6947DAB68E7B931

git clone https://aur.archlinux.org/aide.git /tmp/aide

makepkg -sric --dir /tmp/aide --noconfirm

exit

usermod -a -G libvirt sysadmin




### TECHNICAL


systemctl enable systemd-networkd.socket

systemctl enable systemd-resolved

echo "cryptdevice=UUID=$(blkid -s UUID -o value /dev/nvme0n1p3):crypto root=/dev/proc/root" > /etc/cmdline.d/01-boot.conf

echo "data UUID=$(blkid -s UUID -o value /dev/nvme0n1p4) none" >> /etc/crypttab

echo "intel_iommu=on i915.fastboot=1" >> /etc/cmdline.d/02-mods.conf

mv /boot/intel-ucode.img /boot/vmlinuz-linux-hardened /boot/kernel

rm /boot/initramfs-*

bootctl --path=/boot/ install

touch /etc/vconsole.conf

systemctl enable firewalld

systemctl enable sshd

systemctl enable tangd.socket

systemctl enable apparmor.service

cp /etc/pacman.d/mirrorlist /etc/pacman.d/backupmirror 

systemctl enable tuned-ppd

systemctl enable irqbalance.service

systemctl enable libvirtd.socket

chown root:root /etc/crontab && chmod og-rwx /etc/crontab

chown root:root /etc/cron.hourly/ && chmod og-rwx /etc/cron.hourly/

chown root:root /etc/cron.daily/ && chmod og-rwx /etc/cron.daily/

chown root:root /etc/cron.weekly/ && chmod og-rwx /etc/cron.weekly/

chown root:root /etc/cron.monthly/ && chmod og-rwx /etc/cron.monthly/

chown root:root /etc/cron.d/ && chmod og-rwx /etc/cron.d

modprobe -r hfs 2> /dev/null && rmmod hfs 2> /dev/null 

modprobe -r hfsplus 2> /dev/null && rmmod hfsplus 2> /dev/null

modprobe -r jffs2 2> /dev/null && rmmod jffs2 2> /dev/null

modprobe -r squashfs 2> /dev/null && rmmod squashfs 2> /dev/null

modprobe -r udf 2> /dev/null && rmmod udf 2> /dev/null

## disable usb-storage file system module from kernel
## modprobe -r usb-storage 2>/dev/null; rmmod usb-storage 2>/dev/null

modprobe -r 9p 2> /dev/null && rmmod 9p 2> /dev/null

modprobe -r affs 2> /dev/null && rmmod affs 2> /dev/null

modprobe -r afs 2> /dev/null && rmmod afs 2> /dev/null

modprobe -r fuse 2> /dev/null && rmmod fuse 2> /dev/null

systemctl mask nfs-server.service

modprobe -r dccp 2> /dev/null && rmmod dccp 2>/dev/null

modprobe -r rds 2> /dev/null && rmmod rds 2> /dev/null

modprobe -r sctp 2> /dev/null && rmmod sctp 2> /dev/null

mkinitcpio -P