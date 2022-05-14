IMG=floppy.img

all: boot kernel

boot:
	make -C boot

kernel:
	make -C kernel

image: all
	dd if=/dev/zero of=$(IMG) bs=512 count=2880
	mkfs.fat -F 12 $(IMG)
	mcopy -i $(IMG) kernel/kernel ::/kernel
	dd if=boot/vbr of=$(IMG) bs=1 skip=62 seek=62 count=450 conv=notrunc

run: image
	qemu-system-i386 -machine q35 -fda $(IMG) -monitor stdio

clean:
	make -C kernel clean
	make -C boot clean
	rm -f floppy.img

.PHONY: all boot kernel image run clean