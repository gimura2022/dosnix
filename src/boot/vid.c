#include <boot/vid.h>

void lputc(char c)
{
	if (c == '\n') lputc('\r');
	vidint_print_char(c);
}

void lputs(const char* s)
{
	for (const char* ptr = s; *ptr != 0; ptr++) lputc(*ptr);
}
