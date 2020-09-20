/*
 * exram.S
 *
 * Created: 2020/09/06 21:40:44
 *  Author: hosuseri
 */

	#include <avr/io.h>

	.equ bank_port, 0x1c00  ; 0001 1100 0000 0000
	.equ baud_rate, 25  ; 38400 baud
	.equ exram_L_start, 0x2000
	.equ exram_H_start, 0x8000

	.text

	.global	mem_write
mem_write:
	mov	r21, r1
	inc	r21

	ldi	r18, 1<<SRE
	out	_SFR_IO_ADDR(MCUCR), r18

	ldi	r18, lo8(baud_rate)
	ldi	r17, hi8(baud_rate)
	rcall	usart_init

	mov	r18, r1 ; 0000 0000
	rcall	set_bank
	ldi	r26, lo8(exram_H_start)
	ldi	r27, hi8(exram_H_start)
	mov	r24, r1
	mov	r25, r1
	ldi	r22, 0x1f
	rcall	wrloop

	ldi	r18, 0x20 ; 0010 0000
	rcall	set_bank
	ldi	r26, lo8(exram_L_start)
	ldi	r27, hi8(exram_L_start)
	ldi	r22, 0xff
	rcall	wrloop

	ldi	r18, 0x40 ; 0100 0000
	rcall	set_bank
	ldi	r26, lo8(exram_H_start)
	ldi	r27, hi8(exram_H_start)
	ldi	r22, 0xff
	rcall	wrloop

	ldi	r18, 0x60 ; 0110 0000
	rcall	set_bank
	ldi	r26, lo8(exram_H_start)
	ldi	r27, hi8(exram_H_start)
	ldi	r22, 0xff
	rjmp	wrloop

	.global mem_read
mem_read:
	mov	r24, r1
	mov	r25, r1
	mov	r23, r1

	mov	r18, r1 ; 0000 0000
	rcall	set_bank
	ldi	r26, lo8(exram_H_start)
	ldi	r27, hi8(exram_H_start)
	ldi	r22, 0x1f
	rcall	rdloop

	ldi	r18, 0x20 ; 0010 0000
	rcall	set_bank
	ldi	r26, lo8(exram_L_start)
	ldi	r27, hi8(exram_L_start)
	ldi	r22, 0xff
	rcall	rdloop

	ldi	r18, 0x40 ; 0100 0000
	rcall	set_bank
	ldi	r26, lo8(exram_H_start)
	ldi	r27, hi8(exram_H_start)
	ldi	r22, 0xff
	rcall	rdloop

	ldi	r18, 0x60 ; 0110 0000
	rcall	set_bank
	ldi	r26, lo8(exram_H_start)
	ldi	r27, hi8(exram_H_start)
	ldi	r22, 0xff
	rjmp	rdloop

rdloop:
	rcall	prn_hex6
	ldi	r18, ' '
	rcall	usart_transmit
1:	ld	r18, x+
	rcall	prn_hex2

	add	r24, r21
	adc	r25, r1
	adc	r23, r1

	mov	r18, r26
	andi	r18, 0xf
	breq	2f
	ldi	r18, ' '
	rcall	usart_transmit
	rjmp	1b
2:	ldi	r18, 0x0d
	rcall	usart_transmit
	ldi	r18, 0x0a
	rcall	usart_transmit
	mov	r0, r27
	and	r0, r22
	or	r0, r26
	brne	rdloop
	ret

wrloop:
	st	x+, r24
	st	x+, r25
	add	r24, r21
	adc	r25, r1
	mov	r0, r27
	and	r0, r22
	or	r0, r26
	brne	wrloop
	ret

prn_hex2:
	mov	r0, r18
	lsr	r18
	lsr	r18
	lsr	r18
	lsr	r18
	andi	r18, 0xf
	rcall	1f
	mov	r18, r0
	andi	r18, 0xf
	rjmp	1f
1:	cpi	r18, 10
	brlt	2f
	ldi	r17, 'A' - 10
	add	r18, r17
	rjmp	usart_transmit
2:	ldi	r17, '0'
	add	r18, r17
	rjmp	usart_transmit

prn_hex4:
	movw	r2, r18
	mov	r18, r3
	rcall	prn_hex2
	mov	r18, r2
	rjmp	prn_hex2

prn_hex6:
	mov	r18, r23
	rcall	prn_hex2
	movw	r18, r24
	rjmp	prn_hex4

usart_transmit:
	; wait for empty transmit 
	sbis	_SFR_IO_ADDR(UCSR0A), UDRE0
	rjmp	usart_transmit

	; put data (r18) into buffer, sends the data
	out	_SFR_IO_ADDR(UDR0), r18
	ret

usart_init:
	; set baud ratebuffer
	out	_SFR_IO_ADDR(UBRR0H), r17
	out	_SFR_IO_ADDR(UBRR0L), r18

	;enable receiver and transmitter
	ldi	r18, (1<<RXEN0)|(1<<TXEN0)
	out	_SFR_IO_ADDR(UCSR0B), r18

	; set frame format: 8 data, 2stop bit
	ldi	r18, (1<<URSEL0)|(1<<USBS0)|(3<<UCSZ00)
	out	_SFR_IO_ADDR(UCSR0C), r18
	ret

set_bank:
	sts	bank_port, r18
	ret

	.end
