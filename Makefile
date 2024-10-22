ASMC = nasm
CC   = /usr/local/i386elfgcc/bin/i386-elf-gcc
LD   = /usr/local/i386elfgcc/bin/i386-elf-ld
DD   = dd
CP   = cp

ASMPPFLAGS = -I include
CPPFLAGS = -I include -I /usr/local/i386elfgcc/lib/gcc/i386-elf/12.2.0/include
CFLAGS = -Wall -m16 -nostdlib -nostartfiles -std=c99 -finput-charset=ascii

S = src

IMG    = dosnix.img
FS_MNT = fs

KERNEL_SRC = $(S)/kernel/kernel.asm
KERNEL_OBJ = $(KERNEL_SRC:.asm=.o)

.PHONY: all
all: install

.PHONY: install
install: $(IMG) kernel.sys boot.bin
	$(DD) conv=notrunc if=boot.bin of=$(IMG)

	mkdir -p $(FS_MNT)
	mount $(IMG) $(FS_MNT)
	$(CP) kernel.sys $(FS_MNT)/kernel.sys
	umount $(FS_MNT)

kernel.sys: kernel.o
	$(CP) kernel.o kernel.sys

kernel.o: $(KERNEL_OBJ)
	$(CP) $(KERNEL_OBJ) kernel.o

boot.bin: $(S)/boot/mbr.asm loader.bin
	$(ASMC) -f bin -o $@ $(S)/boot/mbr.asm $(ASMPPFLAGS)

LOADER_ASM_SRC = $(S)/boot/asm_boot.asm $(S)/boot/asm_vid.asm
LOADER_C_SRC = $(S)/boot/boot.c $(S)/boot/vid.c
LOADER_OBJ = $(LOADER_ASM_SRC:.asm=.o) $(LOADER_C_SRC:.c=.o)

loader.bin: $(LOADER_OBJ)
	echo $(LOADER_OBJ)

	$(LD) -o $@ -Ttext 0x7e00 $(LOADER_OBJ) --oformat binary

$(IMG):
	$(DD) bs=512 count=2880 if=/dev/zero of=$(IMG)

%.o: %.asm
	$(ASMC) -f elf -o $@ $< $(ASMPPFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $< $(CPPFLAGS)

%.c: %.h

.PHONY: clean
clean:
	rm -f kernel.sys kernel.o loader.bin loader.o $(IMG) $(KERNEL_OBJ) $(LOADER_OBJ)
	rm -r $(FS_MNT)