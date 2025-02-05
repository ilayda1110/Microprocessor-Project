;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

start:
	bic.b #10111110b, &P1SEL ; make P1.1, 2, 3, 4, 5, and 7 Digital I/O
	bic.b #10111110b, &P1SEL2 ; make P1.1, 2, 3, 4, 5, and 7 Digital I/O
	bic.b #11011101b, &P2SEL ; make P2.0, 2, 3, 4, 6, and 7 Digital I/O
	bic.b #11011101b, &P2SEL2 ; make P2.0, 2, 4, 6, and 7 Digital I/O

	bis.b #10110110b, &P1DIR ; make P1.1, 2, 4, 5, and 7 output
	bis.b #01001101b, &P2DIR ; make P2.0, 2, 3 and 6 output
	bic.b #10010000b, &P2DIR ; make P2.4 and 7 input
	bic.b #00001000b, &P1DIR ; Make P1.3 Input

	bis.b #10010000b, &P2REN ; enable pull-up resistor for P2.4 and 7
	bis.b #10010000b, &P2OUT ; enable pull-up resistor for P2.4 and 7
	bis.b #00001000b, &P1REN ; Enable pull-up resistor for 1.3
	bis.b #00001000b, &P1OUT ; Enable pull-up resistor for 1.3

	bic.b #00010000b, &P2IFG ; Clear interrupt flag for P2.4
	bic.b #10000000b, &P2IFG ; Clear interrupt flag for P2.7
	bic.b #00001000b, &P1IFG ; Clear interrupt flag for P1.3

	bis.w #GIE, SR ; enable interrupts
	bis.b #00010000b, &P2IES ; Set P2.4 to trigger interrupt
	bis.b #00010000b, &P2IE ; Enable interrupt on P2.4
	bis.b #10000000b, &P2IES ; Set P2.7 to trigger interrupt
	bis.b #10000000b, &P2IE ; Enable interrupt on P2.7
	bis.b #00001000b, &P1IES ; Set P1.3 to trigger interrupt
	bis.b #00001000b, &P1IE ; Enable interrupt on P1.3

	mov.w #1, r6 ; move 1 into r6 to mark that the timer has not yet ended
	mov.w #23, r5 ; move 23 into r5 for delay timing
	bic.b #BIT3|BIT6, &P2OUT ; Turn off LEDs

display3:
	bis.b #10110110b, &P1OUT ; All segments OFF
	bis.b #00000101b, &P2OUT ; All segments OFF
	bic.b #00110110b, &P1OUT ; Turn on "3"
	bic.b #00000100b, &P2OUT ; Turn on "3"
	call #delay

display2:
	bis.b #10110110b, &P1OUT ; All segments OFF
	bis.b #00000101b, &P2OUT ; All segments OFF
	bic.b #10100110b, &P1OUT ; Turn on "2"
	bic.b #00000100b, &P2OUT ; Turn on "2"
	call #delay

display1:
	bis.b #10110110b, &P1OUT ; All segments OFF
	bis.b #00000101b, &P2OUT ; All segments OFF
	bic.b #00010100b, &P1OUT ; Turn on "1"
	call #delay

displayDone:
	bis.b #10110110b, &P1OUT ; All segments OFF
	bis.b #00000101b, &P2OUT ; All segments OFF
	bic.b #00000100b, &P2OUT ; Turn on "-"
	mov.w #0, r6 ; move 0 into r6 to mark the timer ended
	jmp noPress


; delay waits for exactly one second when called.
delay:
	mov.w #10868, r4
dloop:
	sub.w #1, r4
	cmp.w #0, r4
	jne dloop
	sub.w #1, r5
	cmp.w #0, r5
	jne delay
	mov.w #23, r5
	ret

win:
	bit.b #00010000b, r7 ; checks if player with yellow LED pressed the button
	jne yellowLED
	jmp blueLED

lose:
	bit.b #00010000b, r7 ; checks if player with yellow LED pressed the button
	jne blueLED
	jmp yellowLED

yellowLED:
	bis.b #BIT3, &P2OUT ; Light yellow LED
	jmp end

blueLED:
	bis.b #BIT6, &P2OUT ; Light blue LED
	jmp end


; Waits for three seconds at the end of the game before restarting
end:
	call #delay
	call #delay
	call #delay
	jmp start


; Loop where we wait until someone presses after "-" is displayed.
noPress:
	call #delay
	jmp noPress


; Interrupt for reset button
but_ISR_Reset:
	jmp start


; Interrupt for player buttons
but_ISR:
	mov.b &P2IFG, r7 ; save the flag in r7 before it gets cleared
	bis.b #10110110b, &P1OUT ; All segments OFF
	bis.b #00000101b, &P2OUT ; All segments OFF
	bic.b #00000100b, &P2OUT ; Turn on "-"
	cmp.w #1, r6 ; check if the timer has ended when the buttons are pressed
	jne win
	jmp lose


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect ".int02" ; Port 1 interrupt vector
   .short but_ISR_Reset
            .sect ".int03" ; Port 2 interrupt vector
   .short but_ISR
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
