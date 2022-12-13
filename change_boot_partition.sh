boot_part=$(hexdump -e '1/1 "%01x|"' -n 1 -s 168 -C /dev/mtd3|cut -f 1 -d "|"|head -n1)

dd if=/dev/mtd2 of=boot.bin bs=336 count=1

if [ ${boot_part} -eq 0 ]; then
  printf '\x01' | dd of=boot.bin bs=1 seek=168 count=1 conv=notrunc
else
  printf '\x00' | dd of=boot.bin bs=1 seek=168 count=1 conv=notrunc

fi

dd if=boot.bin of=/dev/mtd2
dd if=boot.bin of=/dev/mtd3


