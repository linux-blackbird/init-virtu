#!/bin/bash

### ADMINISTRATOR

cryptsetup luksFormat /dev/nvme0n1p2

cryptsetup luksFormat /dev/nvme0n1p3

cryptsetup luksFormat /dev/nvme0n1p4

cryptsetup luksOpen /dev/nvme0n1p2 lvm_keys

yes | mkfs.ext4 -L KEYS /dev/mapper/lvm_keys 

cryptsetup luksOpen /dev/nvme0n1p3 lvm_root

cryptsetup luksOpen /dev/nvme0n1p4 lvm_data


### TECHNICAL

pvcreate /dev/mapper/lvm_root

vgcreate proc /dev/mapper/lvm_root

yes | lvcreate -L 10G proc -n root

yes | lvcreate -L 5G proc -n vars

yes | lvcreate -L 1.5G proc -n vtmp

yes | lvcreate -L 5G proc -n vlog

yes | lvcreate -L 2.5G proc -n vaud

yes | lvcreate -l100%FREE proc -n swap

pvcreate /dev/mapper/lvm_data

vgcreate data /dev/mapper/lvm_data

yes | lvcreate -L 5G data -n home

yes | lvcreate -l100%FREE data -n host

yes | mkfs.vfat -F32 -S 4096 -n BOOT /dev/nvme0n1p1

yes | mkfs.ext4 -b 4096 /dev/data/home

mkfs.xfs -fs size=4096 /dev/data/host

yes | mkfs.ext4 -b 4096 /dev/proc/root

yes | mkfs.ext4 -b 4096 /dev/proc/vars

yes | mkfs.ext4 -b 4096 /dev/proc/vtmp

yes | mkfs.ext4 -b 4096 /dev/proc/vlog

yes | mkfs.ext4 -b 4096 /dev/proc/vaud

yes | mkswap /dev/proc/swap

mount /dev/proc/root /mnt/

mkdir /mnt/boot && mount -o uid=0,gid=0,fmask=0077,dmask=0077 /dev/nvme0n1p1 /mnt/boot

mkdir /mnt/var && mount -o defaults,rw,nosuid,nodev,noexec,relatime /dev/proc/vars /mnt/var

mkdir /mnt/var/tmp && mount -o rw,nosuid,nodev,noexec,relatime /dev/proc/vtmp /mnt/var/tmp

mkdir /mnt/var/log && mount -o rw,nosuid,nodev,noexec,relatime /dev/proc/vlog /mnt/var/log

mkdir /mnt/var/log/audit && mount -o rw,nosuid,nodev,noexec,relatime /dev/proc/vaud /mnt/var/log/audit

mkdir /mnt/home && mount -o rw,nosuid,nodev,noexec,relatime /dev/data/home /mnt/home 

mkdir /mnt/var/lib /mnt/var/lib/libvirt /mnt/var/lib/libvirt/images && mount /dev/data/host /mnt/var/lib/libvirt/images 

swapon /dev/proc/swap

pacstrap /mnt/ linux-hardened linux-firmware mkinitcpio intel-ucode xfsprogs lvm2 base base-devel neovim git openssh polkit less firewalld tang apparmor libpwquality rsync qemu-base libvirt openbsd-netcat reflector nftables tuned tuned-ppd irqbalance

genfstab -U /mnt/ > /mnt/etc/fstab 

cp /etc/systemd/network/* /mnt/etc/systemd/network/

echo 'tmpfs     /tmp        tmpfs   defaults,rw,nosuid,nodev,noexec,relatime,size=1G    0 0' >> /mnt/etc/fstab

echo 'tmpfs     /dev/shm    tmpfs   defaults,rw,nosuid,nodev,noexec,relatime,size=1G    0 0' >> /mnt/etc/fstab

pacman -Syy git --noconfirm

git clone https://github.com/linux-blackbird/virtu

cp -fr conf/cfg/* /mnt/ 

arch-chroot /mnt /bin/bash /tmp/main.sh;



exit


echo "
Do not forget to activate this command bellow after reboot

ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

systemctl restart systemd-networkd

systemctl restart systemd-resolved


you will automaticaly reboot at 20 s 
"


sleep 20
umount -R /mnt

reboot