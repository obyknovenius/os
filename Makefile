floppy.img: boot/vbr kernel/l
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 $@
	mcopy -i $@ kernel/l ::/kernel
	dd if=$< of=$@ bs=1 skip=62 seek=62 count=450 conv=notrunc

boot/vbr: boot/vbr.asm
	nasm -f bin $< -o $@

kernel/l: kernel/l.asm
	nasm -f bin $< -o $@

run: floppy.img
	qemu-system-i386 -machine q35 -fda $< -monitor stdio

clean:
	rm -f floppy.img boot/vbr kernel/l