floppy.img: boot/mbr
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 $@
	dd if=$< of=$@ bs=1 skip=62 seek=62 count=450 conv=notrunc

boot/mbr: boot/mbr.asm
	nasm -f bin $< -o $@

run: floppy.img
	qemu-system-i386 -machine q35 -fda $<

clean:
	rm -f floppy.img boot/mbr