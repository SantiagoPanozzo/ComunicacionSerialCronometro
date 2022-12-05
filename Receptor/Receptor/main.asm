;
; ReceptorRX.asm
;
; Created: 28/11/2022 19:07:28
; Author : Grupo 1
;

.ORG 0x00
rjmp setup
.ORG 0x0020
rjmp frame	;salto atención por overflow
.ORG 0x24
rjmp RX


; Replace with your application code
setup:
    
	; inicializamos el stack pointer
	ldi		r16, high(RAMEND)
	out		SPH, r16
	ldi		r16, low(RAMEND)
	out		SPL, r16

	ldi		r16,	0b00000010	
	out		TCCR0B,	r16			;prescaler = 256 -> 16'000'000 de ciclos del micro, contando 61 fotogramas por segundo, cada fotograma mostrando 4 displays, con el prescaler de 256 configurado a overflow en 255
								; 16000000/(61*4) = 65573 Hz / fps, 256/65573 = 1,004 segundos reales / segundo en display
	ldi		r16,	0b00000001	
	sts		TIMSK0,	r16			;habilito la interrupción (falta habilitar global)
	ldi		r16, 0x00;
	out		TCNT0, r16;	

	ldi		r16,	0b10010000
	out		DDRD,	r16			;configuro PD.4 y PD.7 como salidas
	cbi		PORTD,	7			;PD.7 a 0, es el reloj serial, inicializo a 0
	cbi		PORTD,	4			;PD.4 a 0, es el reloj del latch, inicializo a 0

	apagar: ; apagar el display de 7 segmentos
	ldi r16,0b11111111	; apaga todos los sementos
	ldi r17,0b11110000	; de todos los números
	call sacanum		; muestra eso en el display

	ldi r16,0xFF
	out ddrb, r16
	ldi r17, 0x03
	out portb, r17
	ldi r18, 0x08
	ldi r19, 0x40
	sts UBRR0L, r19
	sts UBRR0H, r17
	ldi r20, 0b00100010
	sts UCSR0A, r20
	ldi r21, 0b00000110
	sts UCSR0C, r21
	ldi r22, 0b10010000
	sts UCSR0B, r22

	sei
	
start:
	rjmp start

frame:
	mov r16, r25
	ldi r17, 0b10000000
	call sacanum
	
	mov r16, r26
	ldi r17, 0b01000000
	call sacanum

	mov r16, r27
	ldi r17, 0b00100000
	call sacanum

	mov r16, r28
	ldi r17, 0b00010000
	call sacanum
	

reti



RX :
	lds r17, UDR0
	mov r16, r17			; mov en vez de repetir lds porque toma menos ciclos
	andi r17, 0b11110000	; posicion : r17
	andi r16, 0b00001111	; numero   : r16
	mov r19, r16
	mov r23, r17
	call getnumeros

	; Switch(r17)

	; Case(1000**)
	cpi r17,0b10000000
	breq guardarNum1

	; Case(0100**)
	cpi r17,0b01000000 ; segundo numero
	breq guardarNum2

	; Case(0010**)
	cpi r17,0b00100000
	breq guardarNum3

	; Case(0001**)
	cpi r17,0b00010000
	breq guardarNum4

	; Default
	;ldi r22, 0b00101000
	;out PORTB, r22


	RETI


	; decenas min
	guardarNum1:
	mov r25, r19 ; copia el numero al registro temporal r16 que es el que utiliza sacanum para mostrar en pantalla
	reti

	; unidades min
	guardarNum2:
	mov r26, r19 ; copia el numero al registro temporal r16 que es el que utiliza sacanum para mostrar en pantalla
	ldi r29, 1
	sub r26, r29
	reti

	; decenas seg
	guardarNum3:
	mov r27, r19 ; copia el numero al registro temporal r16 que es el que utiliza sacanum para mostrar en pantalla
	reti

	; unidades seg
	guardarNum4:
	mov r28, r19  ; copia el numero al registro temporal r16 que es el que utiliza sacanum para mostrar en pantalla
	reti

getnumeros:
	cpi r19, 0
	breq cero
	cpi r19, 1
	breq uno
	cpi r19, 2
	breq dos
	cpi r19, 3
	breq tres
	cpi r19, 4
	breq cuatro
	cpi r19, 5
	breq cinco
	cpi r19, 6
	breq seis
	cpi r19, 7
	breq siete
	cpi r19, 8
	breq ocho
	cpi r19, 9
	breq nueve
	fin:
	ret
		
	cero:
		ldi r19, 0b00000011
		rjmp fin
	uno:
		ldi r19, 0b10011111
		rjmp fin
	dos:
		ldi r19, 0b00100101
		rjmp fin
	tres:
		ldi r19, 0b00001101
		rjmp fin
	cuatro:
		ldi r19, 0b10011001
		rjmp fin
	cinco:
		ldi r19, 0b01001001
		rjmp fin
	seis:
		ldi r19, 0b01000001
		rjmp fin
	siete:
		ldi r19, 0b00011111
		rjmp fin
	ocho:
		ldi r19, 0b00000001
		rjmp fin
	nueve:
		ldi r19, 0b00001001
		rjmp fin

;-------------------------------------------------------------------------------------
; La rutina sacanum, envía lo que hay en r16 y r17 al display de 7 segmentos
; r16 - contiene los LEDs a prender/apagar 0 - prende, 1 - apaga
; r17 - contiene el dígito: r17 = 1000xxxx 0100xxxx 0010xxxx 0001xxxx del dígito menos al más significativo.
sacanum: 
	call	dato_serie
	mov		r16, r17
	call	dato_serie
	sbi		PORTD, 4		;PD.4 a 1, es LCH el reloj del latch
	cbi		PORTD, 4		;PD.4 a 0, 
	ret
	;Voy a sacar un byte por el 7seg
dato_serie:
	ldi		r18, 0x08 ; lo utilizo para contar 8 (8 bits)
loop_dato1:
	cbi		PORTD, 7		;SCLK = 0 reloj en 0
	lsr		r16				;roto a la derecha r16 y el bit 0 se pone en el C
	brcs	loop_dato2		;salta si C=1
	cbi		PORTB, 0		;SD = 0 escribo un 0 
	rjmp	loop_dato3
loop_dato2:
	sbi		PORTB, 0		;SD = 1 escribo un 1
loop_dato3:
	sbi		PORTD, 7		;SCLK = 1 reloj en 1
	dec		r18
	brne	loop_dato1; cuando r17 llega a 0 corta y vuelve
	ret