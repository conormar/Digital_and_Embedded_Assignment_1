; Include the ADuC841 SFR definitions
$NOMOD51
$INCLUDE (MOD841)

CSEG
			ORG		0000h			; set origin at start of code segment
			JMP		MAIN			; jump to main program

			ORG		002Bh			; timer 2 interrupt address
			JMP		T2ISR			; jump to interrupt handler

			ORG		0060h			; set origin above interrupt addresses

MYTABLE: 	DB      40,170,213,235,246,249,251,252

MAIN:
; ------ Setup part - happens once only ----------------------------
			LED    EQU     P3.4      ; P3.4 is red LED on eval board
			SPKR   EQU     P3.6


			MOV 	DPTR, 	#MYTABLE

			MOV		IE, #0A0h	     ; enable timer 2 interrupt
			MOV		RCAP2L, #80h
			SETB	TR2			     ; start timer 2

; ------ Loop forever ----------------------------------------------
BLINK:
			CPL   	LED     	   	; change state of red LED
			JB		P2.0, ENABLE 	; enable timer 2 interrupt if switch 1 is high
			MOV		IE, #80h		; disable timer 2 interrupt otherwise
			JMP		CONTINUE
ENABLE:
			MOV		IE, #0A0h		; enable timer 2 interrupt
CONTINUE:
			CALL  	DELAY   	   	; call software delay routine
			JMP   	BLINK   	   	; repeat indefinitely

; ------ Subroutines -----------------------------------------------
DELAY:                   			; delay for time 200ms x 10 ms.
			MOV	  	R5, #020		; set number of repetitions for outer loop
DLY2:
			MOV   	R7, #144		; middle loop repeats 144 times
DLY1:
			MOV   	R6, #255   	 	; inner loop repeats 255 times
			DJNZ  	R6, $			; inner loop 255 x 3 cycles = 765 cycles
			DJNZ  	R7, DLY1		; + 5 to reload, x 144 = 110880 cycles
			DJNZ  	R5, DLY2		; + 5 to reload = 110885 cycles = 10.0264 ms
			RET					    ; return from subroutine

; ------ Interrupt service routine ---------------------------------
T2ISR:		CLR	  	TR2				; stop timer
			CPL	  	P3.6			; flip the bit generating output
			CLR		A				; Clear the accumulator
			MOV		A, P2
			ANL		A, #111b
			MOVC  	A, @A+DPTR		; move the corresponding table value to A
			MOV   	RCAP2H, A		; move the table value to the reload register
			SETB  	TR2				; resume the timer
			CLR   	TF2				; clear flag, doesnt do it itself for timer 2
			RETI					; return from subroutine
; ------------------------------------------------------------------

END
