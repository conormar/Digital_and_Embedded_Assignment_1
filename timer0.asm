; Demo Program - using timer interrupts.
; Written for ADuC841 evaluation board, with UCD extras.
; Brian Mulkeen, September 2016

; Include the ADuC841 SFR definitions
$NOMOD51
$INCLUDE (MOD841)

CSEG
		ORG		0000h		; set origin at start of code segment
		JMP		MAIN		; jump to main program
		
		ORG		000Bh		; timer 0 interrupt address
		JMP		T0ISR		; jump to interrupt handler

		ORG		0060h		; set origin above interrupt addresses	
MAIN:	
; ------ Setup part - happens once only ----------------------------
		MOV		TMOD, #00h	; timer 0 mode 0, not gated
		MOV		IE, #82h	; enable timer 0 interrupt
		SETB	TR0			; start timer 0

; ------ Loop forever (in this example, doing nothing) -------------
LOOP:	NOP
		JMP		LOOP		; do nothing - wait for interrupt

		
; ------ Interrupt service routine ---------------------------------	
T0ISR:		; timer 0 overflow interrupt service routine
		CPL		P3.6		; flip bit to generate output
		RETI				; return from interrupt
; ------------------------------------------------------------------	
		
END