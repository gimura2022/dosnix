#ifndef _vid_h
#define _vid_h

extern void vidint_set_mode(unsigned char mode);
extern void vidint_print_char(char c);

void lputc(char c);
void lputs(const char* s);

#endif
