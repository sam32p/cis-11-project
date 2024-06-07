;PROGRAM FINAL EXAM-INPUT    ;Loop of 5 for stack/array inputs
;PROGRAMMERS 	ANTONIO GIL, Jocelyne Gonzalez, Samantha Parada
.ORIG X3000

AND R4, R4, x0    ;Clear R4
ADD R4, R4, x5    ;R4 = 5, Loop initialization
LEA R0, PROMPT   	 ;Loads Prompt, tells what to do
PUTS

BR INPUTLOOP
ERRORIN
LEA R0, ERRORPROMPT    
PUTS
    ;///////// DONT TOUCH REGISTER 4 WHILE IN LOOP. AFTER LOOP U CAN /////
    ;///////// INPUT PROMPTS //////////
INPUTLOOP
JSR INPUTPROMPT
;     ///// INPUTS  ///////////////////////////////////////
GETC   	 ;GETS HUNDRED INPUT
OUT   	 ;OUTPUT INPUT
ADD R2, R0, x0 ;STORE IN HUNDRED R2
GETC   	 ;Gets tens Input
OUT   	 ;OUTPUTS INPUT
ADD R1, R0, x0    ;STORE INPUT to TENS R1
GETC   	 ;GETS ONES INPUT
OUT   	 ;OUTPUTS

;///////// Numbers Placement //////////////////////////   
LD R3, ASCII    ;ASCII OFFSET x-30, for each

ADD R2, R2, R3
ADD R1, R1, R3
ADD R0, R0, R3    
   	 ;Ensures They are Numbers
   	 ;Should be 0-9
ADD R0, R0, #-9    ;ONES
BRp ERRORIN    ;Checks if Greater than 9
ADD R0, R0, #9    ;Checks if Less than 0
BRn ERRORIN    
ADD R1, R1, #-9    ;TENS
BRp ERRORIN    ; > 9 ?
ADD R1, R1, #9    ; < 0?
BRn ERRORIN    
ADD R2, R2, #-1    ;HUNDREDS
BRp ERRORIN    ; > 1?
ADD R2, R2, #1    ; < 0?
BRn ERRORIN

JSR VALUE    ;Value stored in R3
;Check if Val > 100
LD R1, ONEHUNDRED    ;LD #100 to R0
ADD R0, R1, x0   	 ;Copy R1 to R0
NOT R0, R0
ADD R0, R0, #1   	 ;R0 = -#100
ADD R3, R3, R0   	 ; R3 - 100,
BRp ERRORIN   	 ;If R3 > 100 INVALID INPUT
ADD R3, R3, R1    	 ;Revert R3 back
//////// STORE IN ARRAY ///////////

LD R6, STACK    ;STACK = x4005
ADD R1, R4, #-6    ;R1 = R4 -6; 0 < R4 < 5
ADD R6, R6, R1    ; R6 - R1, for stack storage
STR R3, R6, #0    ;TOP OF STACK AFTER LOOP is x4000

ADD R4, R4, #-1    ;LOOP DECREMENT
BRp INPUTLOOP
; /////////////END INPUT SECTION OF CODE /////////
;//// THIS CODE LOADS VAL FROM STACK ONTO REGISTERS
LDR R0, R6, #0	  ;Val 5 x4000
LDR R1, R6, #1    ; Val 4    x4001
LDR R2, R6, #2    ; Val 3 x4002
LDR R3, R6, #3    ; Val 2 x4003
LDR R4, R6, #4    ; Val 1 x4004
;// Change left Registers as Needed
;/////////PUT CALCULATIONS HERE ////////////
;///////PUT AVG, Min, and Max Val Calculations Here ///////

;///////////////////////////////////////////////////////////////////MIN/MAX CALC
; R0 will be the minimum
; R1 will be the maximum
; R2 will hold the result of R0 and R1
; R3 has two uses:
;	1. a swapping register for values 1 and 2 should they need it
;	2. in preparation for NEXTVAL, the array with the addresses of values 3-5 is sent here
; R4 will be the loop counter for NEXTVAL
; R5 is where values 3 to 5 are actually loaded up
;Current Top is x4000 = R6
LDR R0, R6, #0	;Val 5; want Min x4004
LDR R1, R6, #1	;Val 4; want Max x4003
NOT R1, R1	; 1s’ complement, R1 = NOT R1
ADD R1, R1, #1	; 2s’ complement, R1 = -R1
ADD R2, R0, R1	; R2 = R0 - R1

BRnz LSETUP	; if >= 0, standing doesn’t change, so continue onto loop setup for remaining values
NOT R1, R1	; if branch doesn’t occur, result was positive, R1 must contain the min. remake positive
ADD R1, R1, #1	; R1 is positive again
ADD R3, R0, #0	; copy R0 to R3, temp spot for swapping. currently holds maximum
AND R0, R0, #0	; clear R0
ADD R0, R1, #0	; copy R1 to R0, now register holds minimum value
AND R1, R1, #0	; now clear R1
ADD R1, R3, #0	; copy R3 to R1, now register holds maximum value
AND R3, R3, #0	; clear R3
AND R2, R2, #0	; clear R2

LSETUP		;Val3 - Val5
ADD R3, R6, #2	; load array with addresses of remaining values to R3	x4002 - x4004
AND R4, R4, #0	; clear R4, R4 will be the counter for the loop
ADD R4, R4, #3	; set counter to 3

NEXTVAL
LDR R5, R3, #0	; next value in the array (R3) is sent to R5
NOT R5, R5	; 1s complement, R5 = NOT R5
ADD R5, R5, #1	; R5 is now negative
ADD R2, R1, R5	; R2 = R1 - R5
BRp CHKMIN	; if result positive, R5 < R1 (the max), branch to check if R5 < R0
BRz MINMAX
NOT R5, R5	; otherwise, R5 must be greater than R1, so make positive again to prep for swap
ADD R5, R5, #1	; R5 is positive again
AND R1, R1, #0	; clear R1
ADD R1, R5, #0	; copy R5 into R1, new max
AND R5, R5, #0 	; clear R5
AND R2, R2, #0	; clear R2
BR MINMAX	; since a reassignment has occurred, can just move onto next value

CHKMIN		; if branch here, R5 < R1, now check if R5 < 0
ADD R2, R0, R5	; R2 = R0 - R5
BRnz MINMAX	; if result negative, R0 < R5; if zero, R0 and R5 are the same. in either case, move on
NOT R5, R5	; otherwise, result is positive, meaning R0 > R5. make positive again
ADD R5, R5, #1	; R5 is positive again
AND R0, R0, #0	; clear R0
ADD R0, R5, #0	; copy R5 into R0, new min
AND R5, R5, #0	; clear R5
AND R2, R2, #0	; clear R2

MINMAX		; stores current min/max values away
STI R0, MIN	; stores R0 to MIN
STI R1, MAX	; stores R1 to MAX

ADD R3, R3, #1	; move to next value in array (R3)
ADD R4, R4, #-1	; decrement loop counter
BRp NEXTVAL	; loops as long as counter value is positive
;//////////////////////////////////////////////////////////////////END MIN/MAX

;//////////////////////////////////////////////////////////////////AVG
LD R6, STACK    ; Reload stack pointer
ADD R6, R6, #-5 ; Initialize stack pointer for sum loop x4000

;////////Calculate Average///////////////
AND R5, R5, x0    ; Clear R5 for sum
AND R1, R1, x0    ; Clear R1 for loop counter
ADD R1, R1, #5    ; Initialize loop counter to 5

;/////Loop to add all scores//////////
SUM_LOOP
LDR R3, R6, #0    ; Load the current score from the stack
ADD R5, R5, R3    ; Add the score to the sum
ADD R6, R6, #1    ; Move to the next score in the stack
ADD R1, R1, #-1   ; Decrement loop counter
BRp SUM_LOOP      ; Repeat loop if not done
ADD R0, R5, x0	  ;R0 = R5
AND R1, R1, x0	  ;Clear R1
ADD R1, R1, #5	  ;R1 = 5
JSR DIV		;R2 = R0/R1 = SumofVal/5
STI R2, AVGVAL

;///// END OF CALCULATIONS SECTION OF CODE ////

;R4 - Val 1	

;/////// OUT/DISPLAY HERE     ////////////
LEA R0, MAXPROMPT
PUTS
LDI R4, MAX
JSR SCOREOUT  ;(PArameter R4)
ADD R0, R4, x0	;Copy R4 to R0 
AND R1, R1, x0	;Clear R1
ADD R1, R1, #10	;R1 = #10 
JSR DIV	;Test Val / 10
JSR LETTERGRADE

;///////////////
LEA R0, MINPROMPT
PUTS
LDI R4, MIN
JSR SCOREOUT ;R4 parameter, doesn't touch
ADD R0, R4, x0	;Copy R4 to R0 
AND R1, R1, x0	;Clear R1
ADD R1, R1, #10	;R1 = #10 
JSR DIV	;Test Val / 10
JSR LETTERGRADE
;///OUTPUT LETTER AND NUMBER HERE //////////

;///////////////////////
LEA R0, AVGPROMPT
PUTS
LDI R4, AVGVAL
JSR SCOREOUT	;Display Avg w/ R4 para
ADD R0, R4, x0	;Copy R4 to R0 
AND R1, R1, x0	;Clear R1
ADD R1, R1, #10	;R1 = #10
JSR DIV	;Test Val / 10
JSR LETTERGRADE	;Gives Letter

;///////////////////////

HALT

;//////////////////SUBROUTINES///////////////////////////////

;;/////////LETTERGRADE SUBROUTINE- DISPLAY GRADE LETTER///////
LETTERGRADE ;Parameter R2, Reesult stored in R3
STI R7, SAVER7
AND R3, R3, x0	;Clear R3 = 0 = F
ADD R2, R2, #-5	;Subtract 5 from R2
BRnz LETTER
ADD R3, R3, x1	;R3 = 1 = D
ADD R2, R2 #-1	;Subtract 1 from R2 (-6)
BRnz LETTER
ADD R3, R3, x1	;R3 = 2 = C
ADD R2, R2 #-1	;Subtract 1 from R2 (-7)
BRnz LETTER
ADD R3, R3, x1	;R3 = 3 = B
ADD R2, R2 #-1	;Subtract 1 from R2 (-8)
BRnz LETTER	;R3 = 4 = A
ADD R3, R3, x1	;IF REACH HERE, ITS 9 or more, A
LETTER
;//Displays Letter
LEA R0, LETTERSTRING	;R3 = loop initialization
ADD R3, R3, x0	;BR check condition
BRz LETTERDISPLAY ;CHECKS IF 0, or F
LETTERLOOP	;Loops prompt to correct one
ADD R0, R0, #4	;Amount of space between prompts
ADD R3, R3, #-1	;Decrement Loop
BRp LETTERLOOP
LETTERDISPLAY	;DISPLAY LETTER
PUTS
LDI R7, SAVER7
RET

;;////////TEST SCORE DISPLAY SUBROUTINE ////////////
SCOREOUT	;(Parameter R4), Will Display The number to Console
STI R7, SAVER7	;Saves R7, so we can jump back later
STI R4, SAVER4	;Save R4 to restore later
ADD R0, R4, x0	;Copy R4 to R0 for JSR DIV
LD R1, ONEHUNDRED	;R1 = #100
NOT R1, R1
ADD R1, R1, #1		;R1 = -#100
ADD R4, R4, R1		; R4 = R4 - 100 
BRnp NOTHUND		;Check if R4 = 100
LEA R0, ITSHUND		;Loads "100" string
PUTS			;;Displays 100
BR ENDSCORE		
NOTHUND
AND R1, R1, x0	;Clear R1
ADD R1, R1, #10	;R1 = 10
JSR DIV		;R4/10 	(R0 has Remainder, R2 = Quotient)
LD R3, ASCII	;R3 = -x30
NOT R3, R3
ADD R3, R3, #1	;R3 = x30
ADD R2, R2, R3	; R2 = Quotient + Ascii Offset
ADD R4, R0, x0	;Copy R0 to R4, Remainder in R4
ADD R0, R2, x0	;COpy R2 Val to R0 for OUtput
OUT
ADD R0, R4, R3	;Loads Reaminder + ASCII
OUT
ENDSCORE	;When Exit it will Display
LDI R7, SAVER7	;Reloads R7 to Jump back
LDI R4, SAVER4
RET	;

;////////DIV SUBROUTINE/////////
;NOTE DIV ONLY ACCEPT POS NUMBERS
DIV	;Parameter ( R0 - Divided, R1 - Divisor, R2 = Qutient, R0 is Remainder)
NOT R1, R1	;Turning R1 Negative
ADD R1, R1, x1	;To subtract from divisor
AND R2, R2, X0	;Clear R2
DIVLOOP
ADD R2, R2, #1	;Adds 1 to quotient
ADD R0, R0, R1	;R0 = R0 - R1
BRzp	DIVLOOP ;When Neg, Quotient Foun
ADD R2, R2, #-1
NOT R1, R1
ADD R1, R1, x1	;Turning pos to Add
ADD R0, R0, R1	;Add back Val for Remainder
RET	;JMP R7, R2 = Result

;////////INPUT SUBROUTINE PROMPT///////
INPUTPROMPT
STI R7, SAVER7	;Save R7
LEA R0, LF
PUTS    ; New Line
LEA R0, INPUTS    ;loads "Input Score x" into r0
ADD R3, R4, x0    ;R3 = R4
NOT R3, R3    ; (-)    
ADD R3, R3, x1    ;R3 = -R4
ADD R3, R3, #5    ;R3 = R3 + 5	;For Prompt Loop
BRz DISPLAY     ;For first time in loop

PROMPTLOOP
ADD R0, R0, #14    ;ADD 14 to go to
		   ;     next prompt
ADD R3, R3, #-1    ;Loop Decrement
BRp PROMPTLOOP    
DISPLAY   	 ;DISPLAYS the prompt
PUTS   	 ;outputs prompt   
LDI R7, SAVER7	;Restore R7 
RET

; ///////  Value Subroutine //////
   	 ;Parameters R0 = 100s, R1 = 10s, R2 = 1s
   	 ;Value stored in R3
VALUE   	 ;Combines inputs to 1 number    	 
AND R3, R3, x0    ;Clear R3

ADD R2, R2, x0    ;Checks if 100s = 0
BRz TENSVALUE

; HUNDREDS PLACE
LD R5, ONEHUNDRED    ;Loads #100 to R5
ADD R3, R3, R5    ;Adds #100 to R3

TENSVALUE
ADD R1, R1, x0    ;Checks if 10s = 0
BRz ONESVALUE    ;Goes to 1s if 0
TENSLOOP
ADD R3, R3, #10    ;Adds 10 to R3
ADD R1, R1, #-1    ;Decrement 10s loop by 1
BRp TENSLOOP

ONESVALUE    ;Ones Place ; Note not a loop, just didn't know what to name it
ADD R3, R3, R0    ;R3 = The true value of the inputs
RET   	 ;JMP R7    ;R3 = value

;////////////////////DATA//////////////////
STACK   	 .FILL x4005    ;Note Stack will take values x4000 - x4005
ASCII   	 .FILL x-30    ;ASCII OFfset
ONEHUNDRED    	 .FILL #100     ; #100 For loading
MAX		.FILL x4006	;Holds Max Val
MIN		.FILL x4007	;Holds Min Val
AVGVAL		.FILL x4008	;Holds Avg Val
SAVER7		.FILL x4009	;Saves R7 for traps
SAVER4		.FILL x400A	;Saves R4 for restore
PROMPT   	.STRINGZ "Enter Num as 061"    ;Tells user what to Input
LF   		.STRINGZ "\n"   	 ; New Line

ERRORPROMPT	.STRINGZ " Enter as 091"	

MAXPROMPT	.STRINGZ "\nMax Score is " ;Prompt for Max
MINPROMPT	.STRINGZ "\nMin Score is " ;Prompt for Min
AVGPROMPT	.STRINGZ "\nAvg Score is " ;Prompt for Avg
ITSHUND		.STRINGZ "100"		;Prompt string for 100
LETTERSTRING	.STRINGZ "- F"
		.STRINGZ "- D" ;3+1 = 4 ch
		.STRINGZ "- C"
		.STRINGZ "- B"
		.STRINGZ "- A"
INPUTS   	 .STRINGZ "Input Test 1:" ;13 + 1 = 14 characters    
   		 .STRINGZ "Input Test 2:"
   		 .STRINGZ "Input Test 3:"
   		 .STRINGZ "Input Test 4:"
   		 .STRINGZ "Input Test 5:"

.END
