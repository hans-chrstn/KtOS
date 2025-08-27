generate rootfs:
    rootfs/
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

generate iso:
grub-mkrescue -o myiso.iso iso/

fix bash tty problem:
    rootfs/dev
mknod console c 5 1
mknod tty0 c 4 0
mknod null c 1 3
chmod 600 console
chmod 666 null

credits to ryanwoodsmall for the static binaries (nixos has been a pain in getting any static binaries)
