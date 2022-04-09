floppy.img: boot/vbr kernel/kernel
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 $@
	mcopy -i $@ kernel/kernel ::/kernel
	dd if=$< of=$@ bs=1 skip=62 seek=62 count=450 conv=notrunc

boot/vbr:
	make -C boot vbr

kernel/kernel: 
	make -C kernel kernel

run: floppy.img
	qemu-system-i386 -machine q35 -fda $< -monitor stdio

clean:
	make -C kernel clean
	make -C boot clean
	rm -f floppy.img