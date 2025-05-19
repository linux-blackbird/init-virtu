#!/bin/bash

PATH=$(pwd)

source $PATH/env

echo blackbird > /etc/hostname &
pid=$!
wait $pid

ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime &
pid=$!
wait $pid

hwclock --systohc &
pid=$!
wait $pid 

timedatectl set-ntp true &
pid=$!
wait $pid

printf "en_US.UTF-8 UTF-8\nen_US ISO-8859-1" >> /etc/locale.gen &
pid=$!
wait $pid

locale-gen && locale > /etc/locale.conf &
pid=$!
wait $pid

sed -i '1s/.*/'LANG=en_US.UTF-8'/' /etc/locale.conf &
pid=$!
wait $pid

echo 'EDITOR="/usr/bin/nvim"' >> /etc/environment &
pid=$!
wait $pid



### ADMINISTRATOR

useradd -m sysadmin &
pid=$!
wait $pid

chown -R sysadmin:sysadmin /home/sysadmin &
pid=$!
wait $pid

echo 'sysadmin ALL=(ALL:ALL) ALL' > /etc/sudoers.d/00_sysadmin &
pid=$!
wait $pid

passwd sysadmin &
pid=$!
wait $pid

usermod -a -G wheel sysadmin &
pid=$!
wait $pid

usermod -a -G libvirt sysadmin &
pid=$!
wait $pid





### TECHNICAL


systemctl enable systemd-networkd.socket &
pid=$!
wait $pid

systemctl enable systemd-resolved &
pid=$!
wait $pid

echo "cryptdevice=UUID=$(blkid -s UUID -o value /dev/$DISK_ROOT):crypto root=/dev/proc/root" > /etc/cmdline.d/01-boot.conf &
pid=$!
wait $pid

echo "data UUID=$(blkid -s UUID -o value /dev/$DISK_DATA) none" >> /etc/crypttab &
pid=$!
wait $pid

echo "intel_iommu=on i915.fastboot=1" >> /etc/cmdline.d/02-mods.conf &
pid=$!
wait $pid

mv /boot/intel-ucode.img /boot/vmlinuz-linux-hardened /boot/kernel &
pid=$!
wait $pid

rm /boot/initramfs-* &
pid=$!
wait $pid

bootctl --path=/boot/ install &
pid=$!
wait $pid

touch /etc/vconsole.conf &
pid=$!
wait $pid

systemctl enable firewalld &
pid=$!
wait $pid

systemctl enable sshd &
pid=$!
wait $pid

systemctl enable apparmor.service &
pid=$!
wait $pid

cp /etc/pacman.d/mirrorlist /etc/pacman.d/backupmirror &
pid=$!
wait $pid 

systemctl enable tuned-ppd &
pid=$!
wait $pid

systemctl enable irqbalance.service &
pid=$!
wait $pid

systemctl enable libvirtd.socket &
pid=$!
wait $pid

chown root:root /etc/crontab && chmod og-rwx /etc/crontab &
pid=$!
wait $pid

chown root:root /etc/cron.hourly/ && chmod og-rwx /etc/cron.hourly/ &
pid=$!
wait $pid

chown root:root /etc/cron.daily/ && chmod og-rwx /etc/cron.daily/ &
pid=$!
wait $pid

chown root:root /etc/cron.weekly/ && chmod og-rwx /etc/cron.weekly/ &
pid=$!
wait $pid

chown root:root /etc/cron.monthly/ && chmod og-rwx /etc/cron.monthly/ &
pid=$!
wait $pid

chown root:root /etc/cron.d/ && chmod og-rwx /etc/cron.d &
pid=$!
wait $pid

modprobe -r hfs 2> /dev/null && rmmod hfs 2> /dev/null &
pid=$!
wait $pid 

modprobe -r hfsplus 2> /dev/null && rmmod hfsplus 2> /dev/null &
pid=$!
wait $pid

modprobe -r jffs2 2> /dev/null && rmmod jffs2 2> /dev/null &
pid=$!
wait $pid

modprobe -r squashfs 2> /dev/null && rmmod squashfs 2> /dev/null &
pid=$!
wait $pid

modprobe -r udf 2> /dev/null && rmmod udf 2> /dev/null &
pid=$!
wait $pid

## disable usb-storage file system module from kernel
## modprobe -r usb-storage 2>/dev/null; rmmod usb-storage 2>/dev/null

modprobe -r 9p 2> /dev/null && rmmod 9p 2> /dev/null &
pid=$!
wait $pid

modprobe -r affs 2> /dev/null && rmmod affs 2> /dev/null &
pid=$!
wait $pid

modprobe -r afs 2> /dev/null && rmmod afs 2> /dev/null &
pid=$!
wait $pid

modprobe -r fuse 2> /dev/null && rmmod fuse 2> /dev/null &
pid=$!
wait $pid

systemctl mask nfs-server.service &
pid=$!
wait $pid

modprobe -r dccp 2> /dev/null && rmmod dccp 2>/dev/null &
pid=$!
wait $pid

modprobe -r rds 2> /dev/null && rmmod rds 2> /dev/null &
pid=$!
wait $pid

modprobe -r sctp 2> /dev/null && rmmod sctp 2> /dev/null &
pid=$!
wait $pid

mkinitcpio -P

exit