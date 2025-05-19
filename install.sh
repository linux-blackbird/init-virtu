#!/bin/bash
DURS=$(pwd)
source $DURS/virtu/env

### ADMINISTRATOR

cryptsetup luksFormat /dev/$DISK_KEYS


cryptsetup luksFormat /dev/$DISK_ROOT


cryptsetup luksFormat /dev/$DISK_DATA


cryptsetup luksOpen /dev/$DISK_KEYS lvm_keys &


yes | mkfs.ext4 -L KEYS /dev/mapper/lvm_keys &
pid=$!
wait $pid 


cryptsetup luksOpen /dev/$DISK_ROOT lvm_root


cryptsetup luksOpen /dev/$DISK_DATA lvm_data 


### TECHNICAL

pvcreate /dev/mapper/lvm_root &
pid=$!
wait $pid

vgcreate proc /dev/mapper/lvm_root &
pid=$!
wait $pid

yes | lvcreate -L 10G proc -n root &
pid=$!
wait $pid

yes | lvcreate -L 5G proc -n vars &
pid=$!
wait $pid

yes | lvcreate -L 1.5G proc -n vtmp &
pid=$!
wait $pid

yes | lvcreate -L 5G proc -n vlog &
pid=$!
wait $pid

yes | lvcreate -L 2.5G proc -n vaud &
pid=$!
wait $pid

yes | lvcreate -l100%FREE proc -n swap &
pid=$!
wait $pid

pvcreate /dev/mapper/lvm_data &
pid=$!
wait $pid

vgcreate data /dev/mapper/lvm_data &
pid=$!
wait $pid

yes | lvcreate -L 5G data -n home &
pid=$!
wait $pid

yes | lvcreate -l100%FREE data -n host &
pid=$!
wait $pid

yes | mkfs.vfat -F32 -S 4096 -n BOOT /dev/$DISK_BOOT &
pid=$!
wait $pid

yes | mkfs.ext4 -b 4096 /dev/data/home &
pid=$!
wait $pid

mkfs.xfs -fs size=4096 /dev/data/host &
pid=$!
wait $pid

yes | mkfs.ext4 -b 4096 /dev/proc/root &
pid=$!
wait $pid

yes | mkfs.ext4 -b 4096 /dev/proc/vars &
pid=$!
wait $pid

yes | mkfs.ext4 -b 4096 /dev/proc/vtmp &
pid=$!
wait $pid
 
yes | mkfs.ext4 -b 4096 /dev/proc/vlog &
pid=$!
wait $pid

yes | mkfs.ext4 -b 4096 /dev/proc/vaud &
pid=$!
wait $pid

yes | mkswap /dev/proc/swap &
pid=$!
wait $pid

mount /dev/proc/root /mnt/ &
pid=$!
wait $pid

mkdir /mnt/boot && mount -o uid=0,gid=0,fmask=0077,dmask=0077 /dev/nvme0n1p1 /mnt/boot &
pid=$!
wait $pid

mkdir /mnt/var && mount -o defaults,rw,nosuid,nodev,noexec,relatime /dev/proc/vars /mnt/var &
pid=$!
wait $pid

mkdir /mnt/var/tmp && mount -o rw,nosuid,nodev,noexec,relatime /dev/proc/vtmp /mnt/var/tmp &
pid=$!
wait $pid

mkdir /mnt/var/log && mount -o rw,nosuid,nodev,noexec,relatime /dev/proc/vlog /mnt/var/log &
pid=$!
wait $pid

mkdir /mnt/var/log/audit && mount -o rw,nosuid,nodev,noexec,relatime /dev/proc/vaud /mnt/var/log/audit &
pid=$!
wait $pid

mkdir /mnt/home && mount -o rw,nosuid,nodev,noexec,relatime /dev/data/home /mnt/home &
pid=$!
wait $pid 

mkdir /mnt/var/lib /mnt/var/lib/libvirt /mnt/var/lib/libvirt/images && mount /dev/data/host /mnt/var/lib/libvirt/images & 
pid=$!
wait $pid

swapon /dev/proc/swap &
pid=$!
wait $pid

pacstrap /mnt/ linux-hardened linux-firmware mkinitcpio intel-ucode xfsprogs lvm2 base base-devel neovim git openssh polkit less firewalld tang apparmor libpwquality rsync qemu-base libvirt openbsd-netcat reflector nftables tuned tuned-ppd irqbalance &
pid=$!
wait $pid

genfstab -U /mnt/ > /mnt/etc/fstab &
pid=$!
wait $pid 

cp /etc/systemd/network/* /mnt/etc/systemd/network/ &
pid=$!
wait $pid

echo 'tmpfs     /tmp        tmpfs   defaults,rw,nosuid,nodev,noexec,relatime,size=1G    0 0' >> /mnt/etc/fstab &
pid=$!
wait $pid

echo 'tmpfs     /dev/shm    tmpfs   defaults,rw,nosuid,nodev,noexec,relatime,size=1G    0 0' >> /mnt/etc/fstab &
pid=$!
wait $pid


cp -fr conf/cfg/* /mnt/ &
pid=$!
wait $pid 


cp -f ./env /mnt/tmp/init &
pid=$!
wait $pid 


arch-chroot /mnt /bin/bash /tmp/main.sh;

umount -R /mnt

echo "
Do not forget to activate this command bellow after reboot

ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

systemctl restart systemd-networkd

systemctl restart systemd-resolved


you will automaticaly reboot at 20 s 
"


sleep 20


reboot