/*
 * GccApplication1.c
 *
 * Created: 2020/09/06 21:39:59
 * Author : hosuseri
 */ 

#include <avr/io.h>

extern void mem_write();
extern void mem_read();

int main(void)
{
    mem_write();
    for (;;)
	mem_read();  /* never returns */
}
