floppy.img: boot/mbr
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=$< of=$@ conv=notrunc

boot/mbr: boot/mbr.asm
	nasm -f bin $< -o $@

run: floppy.img
	qemu-system-i386 -machine q35 -fda $<

clean:
	rm -f floppy.img boot/mbr