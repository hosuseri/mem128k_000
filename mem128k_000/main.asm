;
; mem128k_000.asm
;
; Created: 2020/08/17 20:37:14
; Author : hosuseri
;
; xtal = 16MHz
; Fuses: extended=0xff, high=0xd1, low=0x9f
;

	.equ	ram_end = 0x04ff
	.equ	bank_port = 0x1c00  ; 0001 1100 0000 0000
	.equ	baud_rate = 25  ; 38400 baud
	.equ	exram_L_start = 0x2000
	.equ	exram_H_start = 0x8000

	.org	0x0000
	jmp		start

	.org	0x0038
start:
	clr		r1
	clr		r9
	inc		r9

	ldi		r16, LOW(ram_end)
	out		SPL, r16
	ldi		r16, HIGH(ram_end)
	out		SPH, r16
    ldi		r16, 1<<SRE
	out		MCUCR, r16

	ldi		r16, LOW(baud_rate)
	ldi		r17, HIGH(baud_rate)
	rcall	usart_init

	mov		r16, r1 ; 0000 0000
	call	set_bank
	ldi		r26, LOW(exram_H_start)
	ldi		r27, HIGH(exram_H_start)
	mov		r4, r1
	mov		r5, r1
	ldi		r18, 0x1f
	rcall	wrloop

	ldi		r16, 0x20 ; 0010 0000
	call	set_bank
	ldi		r26, LOW(exram_L_start)
	ldi		r27, HIGH(exram_L_start)
	ldi		r18, 0xff
	rcall	wrloop

	ldi		r16, 0x40 ; 0100 0000
	call	set_bank
	ldi		r26, LOW(exram_H_start)
	ldi		r27, HIGH(exram_H_start)
	ldi		r18, 0xff
	rcall	wrloop

	ldi		r16, 0x60 ; 0110 0000
	call	set_bank
	ldi		r26, LOW(exram_H_start)
	ldi		r27, HIGH(exram_H_start)
	ldi		r18, 0xff
	rcall	wrloop

infloop:
	mov		r6, r1
	mov		r7, r1
	mov		r8, r1

	mov		r16, r1 ; 0000 0000
	call	set_bank
	ldi		r26, LOW(exram_H_start)
	ldi		r27, HIGH(exram_H_start)
	ldi		r18, 0x1f
	rcall	rdloop

	ldi		r16, 0x20 ; 0010 0000
	call	set_bank
	ldi		r26, LOW(exram_L_start)
	ldi		r27, HIGH(exram_L_start)
	ldi		r18, 0xff
	rcall	rdloop

	ldi		r16, 0x40 ; 0100 0000
	call	set_bank
	ldi		r26, LOW(exram_H_start)
	ldi		r27, HIGH(exram_H_start)
	ldi		r18, 0xff
	rcall	rdloop

	ldi		r16, 0x60 ; 0110 0000
	call	set_bank
	ldi		r26, LOW(exram_H_start)
	ldi		r27, HIGH(exram_H_start)
	ldi		r18, 0xff
	rcall	rdloop

	rjmp	infloop

rdloop:
	;movw	r16, r26
	rcall	prn_hex6
	ldi		r16, ' '
	rcall	usart_transmit
rdloop1:
	ld		r16, x+
	rcall	prn_hex2

	add		r6, r9
	adc		r7, r1
	adc		r8, r1

	mov		r16, r26
	andi	r16, 0xf
	breq	rdloop2
	ldi		r16, ' '
	rcall	usart_transmit
	rjmp	rdloop1
rdloop2:
	ldi		r16, 0x0d
	rcall	usart_transmit
	ldi		r16, 0x0a
	rcall	usart_transmit
	mov		r0, r27
	and		r0, r18
	or		r0, r26
	brne	rdloop
	ret

wrloop:
	st		x+, r4
	st		x+, r5
	add		r4, r9
	adc		r5, r1
	mov		r0, r27
	and		r0, r18
	or		r0, r26
	brne	wrloop
	ret

prn_hex2:
	mov		r0, r16
	lsr		r16
	lsr		r16
	lsr		r16
	lsr		r16
	andi	r16, 0xf
	rcall	prn_hex2_1
	mov		r16, r0
	andi	r16, 0xf
	rjmp	prn_hex2_1

prn_hex2_1:
	cpi		r16, 10
	brlt	prnhex2_2
	ldi		r17, 'A' - 10
	add		r16, r17
	rjmp	usart_transmit

prnhex2_2:
	ldi		r17, '0'
	add		r16, r17
	rjmp	usart_transmit

prn_hex4:
	movw	r2, r16
	mov		r16, r3
	rcall	prn_hex2
	mov		r16, r2
	rjmp	prn_hex2

prn_hex6:
	mov		r16, r8
	rcall	prn_hex2
	movw	r16, r6
	rjmp	prn_hex4

usart_transmit:
	; wait for empty transmit 
	sbis	UCSR0A, UDRE
	rjmp	usart_transmit

	; put data (r16) into buffer, sends the data
	out		UDR0, r16
	ret

usart_init:
	; set baud ratebuffer
	out		UBRR0H, r17
	out		UBRR0L, r16

	;enable receiver and transmitter
	ldi		r16, (1<<RXEN)|(1<<TXEN)
	out		UCSR0B, r16

	; set frame format: 8 data, 2stop bit
	ldi		r16, (1<<URSEL0)|(1<<USBS0)|(3<<UCSZ00)
	out		UCSR0C, r16
	ret

set_bank:
	sts		bank_port, r16
	ret
