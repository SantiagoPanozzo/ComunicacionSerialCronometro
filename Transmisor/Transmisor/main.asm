;
; CronometroDefinitivo.asm
;
; Created: 16/11/2022 21:20:44
; Author : Grupo 1
;
.include "m328pdef.inc"
.ORG 0x0000
	rjmp	start		;dirección de comienzo (vector de reset)  
.ORG 0x0008
	rjmp	interrupt	;dirección de interrupción por puerto C (botones)
.ORG 0x0020
	rjmp	envio	;salto atención por overflow
.org 0x0028
	rjmp enviocompleto

; Replace with your application code
start:

	config:

	; configuramos el puerto C como entrada (pin C)
	ldi r16, 0x00
	out DDRC, r16

	; inicializamos el stack pointer
	ldi		r16, high(RAMEND)
	out		SPH, r16
	ldi		r16, low(RAMEND)
	out		SPL, r16

	; establecemos cual grupo utilizar
	ldi r16, 0b0000010
	sts PCICR, r16

	; establecemos el enmascaramiento para que cualquiera de los tres bits (pines) del 1 al 3 pueda causar una interrupción
	; (cualquiera de los tres botones A del shield va a causar que entremos en la función que maneja la interrupción)
	ldi r16, 0b00001110
	sts PCMSK1, r16

	;Configuro el TMR0 y su interrupcion.

	ldi		r16,	0b00000100	
	out		TCCR0B,	r16			;prescaler = 256 -> 16'000'000 de ciclos del micro, contando 61 fotogramas por segundo, cada fotograma mostrando 4 displays, con el prescaler de 256 configurado a overflow en 255
								; 16000000/(61*4) = 65573 Hz / fps, 256/65573 = 1,004 segundos reales / segundo en display
	ldi		r16,	0b00000001	
	sts		TIMSK0,	r16			;habilito la interrupción (falta habilitar global)
	ldi		r16, 0x00;
	out		TCNT0, r16;	

	ldi		r16,	0b11110001	
	out		DDRC,	r16			;3 botones del shield son entradas

	ldi r20, 0x00 ; flag de reset en x00 por defecto
	ldi r30, 0x00 ; flag de si ocurrió la interrupcion que muestra un numero o no (0: ya se mostró el número, 1: aun no se mostró el numero)
	ldi r26, 0x00 ; constante vale siempre 0

	SBI	DDRD, 1
	LDI R17,0X03
	LDI R18,0X40
	STS UBRR0L,R18
	STS UBRR0H,R17
	LDI r19,0B01000010
	STS UCSR0A,r19
	LDI r19,0B00000110
	STS UCSR0C, r19
	LDI r19, 0B01001000
	STS UCSR0B, r19
	
	ldi r30, 0b00100000 ; r30 tiene nuestras flags, en un principio tienen que ser 0 todos los bits

	; habilitamos las interrupciones globales
	sei

; ------------------------------------------------------------------------------------------------------------
; LOOP PRINCIPAL
; ------------------------------------------------------------------------------------------------------------


decenasMin:
	
	; 0
	ldi  r23, 0
	andi r23, 0b00001111
	ldi  r31, 0b10000000
	add  r23, r31
	call unidadesMin

	; 1
	ldi  r23, 1
	andi r23, 0b00001111
	ldi  r31, 0b10000000
	add  r23, r31
	call unidadesMin

	; 2
	ldi  r23, 2
	andi r23, 0b00001111
	ldi  r31, 0b10000000
	add  r23, r31
	call unidadesMin

	; 3
	ldi  r23, 3
	andi r23, 0b00001111
	ldi  r31, 0b10000000
	add  r23, r31
	call unidadesMin

	; 4
	ldi  r23, 4
	andi r23, 0b00001111
	ldi  r31, 0b10000000
	add  r23, r31
	call unidadesMin
	
	; 5
	ldi  r23, 5
	andi r23, 0b00001111
	ldi  r31, 0b10000000
	add  r23, r31
	call unidadesMin

	rjmp decenasMin

unidadesMin:
	; 0
	ldi  r24, 0
	andi r24, 0b00001111
	ldi  r31, 0b01000000
	add  r24, r31
	call decenasSeg

	; 1
	ldi r24, 1
	andi r24, 0b00001111
	ldi  r31, 0b01000000
	add  r24, r31
	call decenasSeg

	; 2
	ldi r24, 2
	andi r24, 0b00001111
	ldi  r31, 0b01000000
	add  r24, r31
	call decenasSeg

	; 3
	ldi r24, 3
	andi r24, 0b00001111
	ldi  r31, 0b01000000
	add  r24, r31
	call decenasSeg

	; 4
	ldi r24, 4
	andi r24, 0b00001111
	ldi  r31, 0b01000000
	add  r24, r31
	call decenasSeg

	; 5
	ldi r24, 5
	andi r24, 0b00001111
	ldi  r31, 0b01000000
	add  r24, r31
	call decenasSeg

	; 6
	ldi r24, 6
	andi r24, 0b00001111
	ldi  r31, 0b01000000
	add  r24, r31
	call decenasSeg

	; 7
	ldi r24, 7
	andi r24, 0b00001111
	ldi  r31, 0b01000000
	add  r24, r31
	call decenasSeg

	; 8
	ldi r24, 8
	andi r24, 0b00001111
	ldi  r31, 0b01000000
	add  r24, r31
	call decenasSeg

	; 9
	ldi r24, 9
	andi r24, 0b00001111
	ldi  r31, 0b01000000
	add  r24, r31
	call decenasSeg

	ret

decenasSeg:
	; 0
	ldi  r27, 0
	andi r27, 0b00001111
	ldi  r31, 0b00100000
	add  r27, r31
	call unidadesSeg

	; 1
	ldi r27, 1
	andi r27, 0b00001111
	ldi  r31, 0b00100000
	add  r27, r31
	call unidadesSeg

	; 2
	ldi r27, 2
	andi r27, 0b00001111
	ldi  r31, 0b00100000
	add  r27, r31
	call unidadesSeg

	; 3
	ldi r27, 3
	andi r27, 0b00001111
	ldi  r31, 0b00100000
	add  r27, r31
	call unidadesSeg

	; 4
	ldi r27, 4
	andi r27, 0b00001111
	ldi  r31, 0b00100000
	add  r27, r31
	call unidadesSeg
	
	; 5
	ldi r27, 5
	andi r27, 0b00001111
	ldi  r31, 0b00100000
	add  r27, r31
	call unidadesSeg

	ret


unidadesSeg:
	; 0
	ldi  r28, 0
	andi r28, 0b00001111
	ldi  r31, 0b00010000
	add  r28, r31
	call segundear

	; 1
	ldi r28, 1
	andi r28, 0b00001111
	ldi  r31, 0b00010000
	add  r28, r31
	call segundear

	; 2
	ldi r28, 2
	andi r28, 0b00001111
	ldi  r31, 0b00010000
	add  r28, r31
	call segundear

	; 3
	ldi  r28, 3
	andi r28, 0b00001111
	ldi  r31, 0b00010000
	add  r28, r31
	call segundear

	; 4
	ldi r28, 4
	andi r28, 0b00001111
	ldi  r31, 0b00010000
	add  r28, r31
	call segundear

	; 5
	ldi r28, 5
	andi r28, 0b00001111
	ldi  r31, 0b00010000
	add  r28, r31
	call segundear

	; 6
	ldi r28, 6
	andi r28, 0b00001111
	ldi  r31, 0b00010000
	add  r28, r31
	call segundear

	; 7
	ldi r28, 7
	andi r28, 0b00001111
	ldi  r31, 0b00010000
	add  r28, r31
	call segundear

	; 8
	ldi r28, 8
	andi r28, 0b00001111
	ldi  r31, 0b00010000
	add  r28, r31
	call segundear

	; 9
	ldi r28, 9
	andi r28, 0b00001111
	ldi  r31, 0b00010000
	add  r28, r31
	call segundear

	ret

segundear:
	; verifica si r20 vale 0xFF, si lo hace salta a la funcion de resetear el timer
	cpi r20, 0xFF
	breq resetarTimer

	; r25 indica la cantidad de fotogramas por segundo a mostrar
	ldi r25, 244

	; loop que muestra el pantalla todos los numeros
	segloop:
	
		; decenas minutos
		sbr r30, 1		; settea la flag de que todavia no entró en la interrupcion que muestra el numero
		num1:
		mov r21, r23
		sbrc r30, 0		; verifica que la flag de la interrupción valga 0 (si vale 0 ya se mostró el numero y podemos pasar al siguiente)
		rjmp num1		; entra en loop hasta que la interrupción de fps limpie la flag

		; unidades minutos
		sbr r30, 1
		num2:
		mov r21, r24
		sbrc r30, 0
		rjmp num2

		; decenas segundos
		sbr r30, 1
		num3:
		mov r21, r27
		sbrc r30, 0
		rjmp num3

		; unidades segundos
		sbr r30, 1
		num4:
		mov r21, r28
		sbrc r30, 0
		rjmp num4

		waiteador:
		cpse r25, r26	; compara si r25 es igual a r26 (que siempre vale 0). (if contador == 0 return)
		rjmp waiteador

	ret		; cuando ya mostramos el numero las 61 veces podemos pasar al siguiente segundo
resetarTimer:
	; vuelve a poner r20 en 0 (no volver a resetear) y salta hacia el inicio del programa
	ldi r20, 0x00
	rjmp decenasMin

envio:
	// aca se envía
	dec r25
	sbrs r30,5
	reti
	sts UDR0, r21
	andi r30, 0b00100000
	andi r30, 0b00000010
	reti 

enviocompleto:
	sbr r30, 0b00100000
	reti

interrupt:
	; leemos el pin c
	in		r29, PINC
	; si el bit 1 está seteado pausamos el timer
	sbrs	r29, 1
	call	boton1
	; si el bit 3 está seteado reiniciamos el timer
	sbrs	r29, 3
	call	boton3
	
	reti

boton1:
	; pausa
	call pause
	ret

pause:
	; comparamos el pin nuevamente, si el bit 2 está seteado quitamos la pausa, si el bit 3 está seteado reiniciamos el timer
	in		r29, PINC
	sbrs	r29, 2
	ret
	sbrs	r29, 3
	call	boton3

	rjmp pause

boton3:
	ldi r20, 0xFF
	ret