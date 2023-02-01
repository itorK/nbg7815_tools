# Script to changing active boot partitions 
# Author: Karol Przybylski <itor@o2.pl>
# 

openwrt_type=$(cat /etc/openwrt_release|grep DISTRIB_TARGET|cut -f 2 -d "'")

if [ ${openwrt_type} == "ipq807x/generic" ]; then
  echo "OpenWrt release"
  boot_part=$(hexdump -e '1/1 "%01x|"' -n 1 -s 168 -C /dev/mtd2|cut -f 1 -d "|"|head -n1)

  dd if=/dev/mtd2 of=boot.bin bs=336 count=1

  if [ ${boot_part} -eq 0 ]; then
    printf '\x01' | dd of=boot.bin bs=1 seek=168 count=1 conv=notrunc
  else
    printf '\x00' | dd of=boot.bin bs=1 seek=168 count=1 conv=notrunc

  fi

  mtd write boot.bin /dev/mtd2
  mtd write boot.bin /dev/mtd3
fi

if [ ${openwrt_type} == "ipq/ipq807x_64" ]; then
  echo "Original Zyxel Firmware"
  primaryboot_hlos=$(cat /proc/boot_info/0:HLOS/primaryboot)
  if [ $primaryboot_hlos -eq 0 ]; then
       echo 1 > /proc/boot_info/0:HLOS/primaryboot
  else
       echo 0 > /proc/boot_info/0:HLOS/primaryboot
  fi
  
  mkdir /tmp/ApplicationData/boot
  cat /proc/boot_info/getbinary_bootconfig > /tmp/ApplicationData/boot/bootconfig_new.bin
  echo 1 > /proc/mtd_writeable
  dd if=/tmp/ApplicationData/boot/bootconfig_new.bin 2>/dev/null | mtd -e "/dev/mtd2" write - "/dev/mtd2" 2>/dev/null
  dd if=/tmp/ApplicationData/boot/bootconfig_new.bin 2>/dev/null | mtd -e "/dev/mtd3" write - "/dev/mtd3" 2>/dev/null
  echo 0 > /proc/mtd_writeable
  sync
fi
