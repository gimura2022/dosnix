#include <boot/boot.h>
#include <boot/vid.h>

void boot_entry(void)
{
	vidint_set_mode(3);

	lputs("Strarting booting dosnix...\n");

	halt();
}
