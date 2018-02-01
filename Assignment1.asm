; Include the ADuC841 SFR definitions
$NOMOD51
$INCLUDE (MOD841)

CSEG
		ORG		0000h		; set origin at start of code segment
		JMP		MAIN		; jump to main program

		ORG		002Bh		; timer 2 interrupt address
		JMP		T2ISR		; jump to interrupt handler

		ORG		0060h		; set origin above interrupt addresses

MAIN:
; ------ Setup part - happens once only ----------------------------
LED    EQU     P3.4      ; P3.4 is red LED on eval board
SPKR   EQU     P3.6

MOV		 IE, #A0h	         ; enable timer 2 interrupt
SETB	 TR2			         ; start timer 2

; ------ Loop forever ----------------------------------------------
BLINK:
      CPL   LED     	   ; change state of red LED
      JB		P2.1, ENABLE ; enable timer 2 interrupt if switch 1 is high
			MOV		IE, #80h		 ; disable timer 2 interrupt otherwise
			JMP		CONTINUE
ENABLE:
			MOV		IE, #A0h		 ; enable timer 2 interrupt
CONTINUE:
			CALL  DELAY   	   ; call software delay routine
			JMP   BLINK   	   ; repeat indefinitely

; ------ Subroutines -----------------------------------------------
DELAY:                   ; delay for time 200ms x 10 ms.
			MOV	  R5, #020		 ; set number of repetitions for outer loop
DLY2:
      MOV   R7, #144		 ; middle loop repeats 144 times
DLY1:
      MOV   R6, #255   	 ; inner loop repeats 255 times
      DJNZ  R6, $			   ; inner loop 255 x 3 cycles = 765 cycles
      DJNZ  R7, DLY1		 ; + 5 to reload, x 144 = 110880 cycles
			DJNZ  R5, DLY2		 ; + 5 to reload = 110885 cycles = 10.0264 ms
      RET					       ; return from subroutine

; ------ Interrupt service routine ---------------------------------
T2ISR:		               ; timer 2 overflow interrupt service routine
		  CPL		SPKR		     ; flip bit to generate output
			CLR		TF2					 ; clear timer 2 overflow flag
		  RETI				       ; return from interrupt
; ------------------------------------------------------------------

END
