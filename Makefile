ASMC = fasm
CC   = gcc
DD   = dd
CP   = cp

S = src

IMG    = dosnix.img
FS_MNT = fs

KERNEL_SRC = $(S)/kernel/kernel.asm
KERNEL_OBJ = $(KERNEL_SRC:.asm=.o)

LOADER_SRC = $(S)/bootloader/bootloader.asm
LOADER_OBJ = $(LOADER_SRC:.asm=.o)

.PHONY: all
all: install

.PHONY: install
install: $(IMG) kernel.sys loader.bin
	$(DD) conv=notrunc if=loader.bin of=$(IMG)

	mkdir -p $(FS_MNT)
	mount $(IMG) $(FS_MNT)
	$(CP) kernel.sys $(FS_MNT)/kernel.sys
	umount $(FS_MNT)

kernel.sys: kernel.o
	$(CP) kernel.o kernel.sys

kernel.o: $(KERNEL_OBJ)
	$(CP) $(KERNEL_OBJ) kernel.o

loader.bin: loader.o
	$(CP) loader.o loader.bin

loader.o: $(LOADER_OBJ)
	$(CP) $(LOADER_OBJ) loader.o

$(IMG):
	$(DD) bs=512 count=2880 if=/dev/zero of=$(IMG)

%.o: %.asm
	$(ASMC) $< $@

.PHONY: clean
clean:
	rm -f kernel.sys kernel.o loader.bin loader.o $(IMG) $(KERNEL_OBJ) $(LOADER_OBJ)
	rm -r $(FS_MNT)