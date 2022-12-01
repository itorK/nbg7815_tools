if [ ! -f "openwrt-ipq807x-generic-zyxel_nbg7815-squashfs-sysupgrade.bin" ]; then
     echo "Cannot find image openwrt-ipq807x-generic-zyxel_nbg7815-squashfs-sysupgrade.bin"
     exit 1
fi

tar xvf ./openwrt-ipq807x-generic-zyxel_nbg7815-squashfs-sysupgrade.bin

primaryboot_hlos=$(cat /proc/boot_info/0:HLOS/primaryboot)
if [ $primaryboot_hlos -eq 0 ]; then
     dd if=/dev/zero of=/dev/mmcblk0p7
     dd if=/tmp/ApplicationData/sysupgrade-zyxel_nbg7815/kernel of=/dev/mmcblk0p7
     echo 1 > /proc/boot_info/0:HLOS/primaryboot
else
     dd if=/dev/zero of=/dev/mmcblk0p3
     dd if=/tmp/ApplicationData/sysupgrade-zyxel_nbg7815/kernel of=/dev/mmcblk0p3
     echo 0 > /proc/boot_info/0:HLOS/primaryboot
fi

primaryboot_rootfs=$(cat /proc/boot_info/rootfs/primaryboot)
if [ $primaryboot_rootfs -eq 0 ]; then
     dd if=/dev/zero of=/dev/mmcblk0p8
     dd if=/tmp/ApplicationData/sysupgrade-zyxel_nbg7815/root of=/dev/mmcblk0p8
     echo 1 > /proc/boot_info/rootfs/primaryboot
else
     dd if=/dev/zero of=/dev/mmcblk0p4
     dd if=/tmp/ApplicationData/sysupgrade-zyxel_nbg7815/root of=/dev/mmcblk0p4
     echo 0 > /proc/boot_info/rootfs/primaryboot
fi


mkdir /tmp/ApplicationData/boot
cat /proc/boot_info/getbinary_bootconfig > /tmp/ApplicationData/boot/bootconfig_new.bin
echo 1 > /proc/mtd_writeable
dd if=/tmp/ApplicationData/boot/bootconfig_new.bin 2>/dev/null | mtd -e "/dev/mtd2" write - "/dev/mtd2" 2>/dev/null
dd if=/tmp/ApplicationData/boot/bootconfig_new.bin 2>/dev/null | mtd -e "/dev/mtd3" write - "/dev/mtd3" 2>/dev/null
echo 0 > /proc/mtd_writeable
sync
reboot
