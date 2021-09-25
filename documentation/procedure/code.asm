LCD		EQU		P0							
SECS	EQU		30H
MINS	EQU		31H
HRS		EQU		32H
YRS		EQU		33H
MONS	EQU		34H
DAYS	EQU		35H
RS		BIT		P2.0						
E		BIT		P2.1							
		ORG 	0H								
		AJMP	MAIN							 	
		ORG 	30H								
MAIN:	ACALL 	lcdInit1						
		ACALL	setTime
		ACALL	setDate
		ACALL	lcdInit2
		ACALL	calendarOn
		AJMP	$
;--------------------------------------------------------------------------------------------------#!
lcdInit1:										
		MOV 	DPTR,#MYCOM			
LOOP1: 	CLR 	A							
		MOVC 	A,@A+DPTR					
		ACALL 	comnWrt							
		INC 	DPTR							
		JNZ 	LOOP1							
		RET
;--------------------------------------------------------------------------------------------------#!
setTime:
		MOV		R0,#60H
		MOV 	DPTR,#MSG1						
		ACALL	printMsg
		MOV 	DPTR,#MSG2
		ACALL	process
		MOV 	DPTR,#MSG3
		ACALL	process
		MOV 	DPTR,#MSG4
		;ACALL	process
		ACALL	AMPM
		ACALL	loadTime
		ACALL	clrScreen
		RET
;--------------------------------------------------------------------------------------------------#!
setDate:
		MOV		R0,#64H
		MOV 	DPTR,#MSG5						
		ACALL	printMsg
		MOV 	DPTR,#MSG6
		ACALL	process
		MOV 	DPTR,#MSG7
		ACALL	process
		MOV 	DPTR,#MSG8
		ACALL	process
		ACALL	loadDate
		ACALL	clrScreen
		RET
;--------------------------------------------------------------------------------------------------#!
lcdInit2:
		MOV		A,#0CH
		ACALL	comnWrt
		MOV		A,#85H
		ACALL	comnWrt
		MOV		A,#"/"
		ACALL	dataWrt
		MOV		A,#88H
		ACALL	comnWrt
		MOV		A,#"/"
		ACALL	dataWrt
		MOV		A,#0C5H
		ACALL	comnWrt
		MOV		A,#":"
		ACALL	dataWrt
		MOV		A,#0C8H
		ACALL	comnWrt
		MOV		A,#":"
		ACALL	dataWrt
		RET
;--------------------------------------------------------------------------------------------------#!
calendarOn:
	C4:	ACALL	updateDays
		ACALL	updateMons
		ACALL	updateYrs
	C1:	ACALL	updateHrs
		ACALL	updateMins
		ACALL	updateSecs
		ACALL	delaySec
		INC		SECS
		MOV		A,SECS
		CJNE	A,#60,C1
		MOV		SECS,#0
		INC		MINS
		MOV		A,MINS
		CJNE	A,#60,C1
		MOV		MINS,#0		
		INC		HRS	
		MOV		A,HRS
		CJNE	A,#12,C2
		MOV		A,6AH
		CJNE	A,#1,C3
		ADD		A,#1
		MOV		6AH,A
		AJMP	C4
	C2:	CJNE	A,#13,C1
		MOV		HRS,#1
	C3:	INC		DAYS
		MOV		A,DAYS
		CJNE	A,#30,C4
		MOV		DAYS,#0
		INC		MONS
		MOV		A,MONS
		CJNE	A,#13,C4
		MOV		MONS,#1
		INC		YRS
		AJMP 	calendarOn
;--------------------------------------------------------------------------------------------------#!
process:
		MOV		A,#0C1H
		ACALL	comnWrt
		ACALL	printMsg
		ACALL	readKey
		ACALL	dataWrt
		SUBB	A,#30H
		MOV		@R0,A
		INC 	R0
		ACALL	readKey
		ACALL	dataWrt
		SUBB	A,#30H
		MOV		@R0,A
		INC 	R0
		ACALL	clrLine
		RET
;--------------------------------------------------------------------------------------------------#!	
AMPM:	MOV		A,#0C1H
		ACALL	comnWrt
		ACALL	printMsg
		ACALL	readKey
		ACALL	dataWrt
		SUBB	A,#30H
		MOV		6AH,A
		RET
;--------------------------------------------------------------------------------------------------#!		
loadTime:	
		MOV		A,60H
		MOV		B,#10
		MUL		AB
		ADD		A,61H
		MOV		HRS,A
		MOV		A,62H
		MOV		B,#10
		MUL		AB
		ADD		A,63H
		MOV		MINS,A
		MOV		SECS,#0
		RET
;--------------------------------------------------------------------------------------------------#!
loadDate:	
		MOV		A,64H
		MOV		B,#10
		MUL		AB
		ADD		A,65H
		MOV		DAYS,A
		MOV		A,66H
		MOV		B,#10
		MUL		AB
		ADD		A,67H
		MOV		MONS,A
		MOV		A,68H
		MOV		B,#10
		MUL		AB
		ADD		A,69H
		MOV		YRS,A
		RET
;--------------------------------------------------------------------------------------------------#!
delaySec:
		MOV		R2,#15
		MOV		TMOD,#1
AGAIN:	MOV		TL0,#1
		MOV		TH0,#53
		SETB	TR0
		JNB		TF0,$
		CLR		TR0
		CLR		TF0
		DJNZ	R2,AGAIN
		RET		
;--------------------------------------------------------------------------------------------------#!
updateSecs:
		MOV		A,#0C9H
		ACALL	comnWrt
		MOV		A,SECS
		MOV		B,#10
		DIV		AB
		ORL		A,#30H
		ACALL	dataWrt
		MOV		A,B
		ORL		A,#30H
		ACALL	dataWrt
		RET
;--------------------------------------------------------------------------------------------------#!
updateMins:
		MOV		A,#0C6H
		ACALL	comnWrt
		MOV		A,MINS
		MOV		B,#10
		DIV		AB
		ORL		A,#30H
		ACALL	dataWrt
		MOV		A,B
		ORL		A,#30H
		ACALL	dataWrt
		RET
;--------------------------------------------------------------------------------------------------#!
updateHrs:
		MOV		A,#0C3H
		ACALL	comnWrt
		MOV		A,HRS
		MOV		B,#10
		DIV		AB
		ORL		A,#30H
		ACALL	dataWrt
		MOV		A,B
		ORL		A,#30H
		ACALL	dataWrt
		RET
;--------------------------------------------------------------------------------------------------#!
updateDays:
		MOV		A,#83H
		ACALL	comnWrt
		MOV		A,DAYS
		MOV		B,#10
		DIV		AB
		ORL		A,#30H
		ACALL	dataWrt
		MOV		A,B
		ORL		A,#30H
		ACALL	dataWrt
		MOV		A,#0CCH
		ACALL	comnWrt
		MOV		A,6AH
		CJNE	A,#1,PM
AM:		MOV		A,#"A"
		ACALL	dataWrt
		MOV		A,#"M"
		ACALL	dataWrt
		RET
PM:		MOV		A,#"P"
		ACALL	dataWrt
		MOV		A,#"M"
		ACALL	dataWrt	
		RET
;--------------------------------------------------------------------------------------------------#!
updateMons:
		MOV		A,#86H
		ACALL	comnWrt
		MOV		A,MONS
		MOV		B,#10
		DIV		AB
		ORL		A,#30H
		ACALL	dataWrt
		MOV		A,B
		ORL		A,#30H
		ACALL	dataWrt
		RET
;--------------------------------------------------------------------------------------------------#!
updateYrs:
		MOV		A,#89H
		ACALL	comnWrt
		MOV		A,#"2"
		ACALL	dataWrt
		MOV		A,#"0"
		ACALL	dataWrt
		MOV		A,YRS
		MOV		B,#10
		DIV		AB
		ORL		A,#30H
		ACALL	dataWrt
		MOV		A,B
		ORL		A,#30H
		ACALL	dataWrt
		RET
;--------------------------------------------------------------------------------------------------#!
printMsg:
LOOP2:	CLR 	A								
		MOVC 	A,@A+DPTR						
		ACALL 	dataWrt							
		INC 	DPTR							
		JNZ 	LOOP2
		RET
;--------------------------------------------------------------------------------------------------#!
clrScreen:
		MOV		A,#01H
		ACALL	comnWrt
		RET
;--------------------------------------------------------------------------------------------------#!
clrLine:
		MOV		A,#0C0H
		ACALL	comnWrt
		MOV		R2,#16
CLL:	MOV		A,#" "
		ACALL 	dataWrt
		DJNZ	R2,CLL
		RET
;--------------------------------------------------------------------------------------------------#!
comnWrt:										;#!Send command to LCD							
		MOV 	LCD,A 							;#!Copy reg A to P1
		CLR 	RS 								;#!RS=0 for command
		SETB 	E 								;#!E=1 for high pulse
		ACALL 	DELAY 							;#!Give LCD some time
		CLR 	E 								;#!E=0 for H-to-L pulse
		RET										;#!return to caller
;--------------------------------------------------------------------------------------------------#!
dataWrt:										;#!Write data to LCD
		MOV 	LCD,A 							;#!Copy reg A to port 1
		SETB 	RS 								;#!RS=1 for data
		SETB 	E								;#!E=1 for high pulse
		ACALL 	DELAY 							;#!Give LCD some time
		CLR 	E 								;#!E=0 for H-to-L pulse
		RET										;#!return to caller
;--------------------------------------------------------------------------------------------------#!
DELAY:											;#!Delay subroutine
		MOV 	R7,#6							;#!R0 = 2
S11:	MOV 	R6,#150							;#!R1 = 255
S21:	DJNZ 	R6,S21							;#!stay here until R1 becomes ZERO
		DJNZ 	R7,S11							;#!
		RET										;#!return to caller
;--------------------------------------------------------------------------------------------------#!
readKey:
		MOV 	P1,#0FFH						;#!Make P1 an input port
K1: 	MOV 	P3,#0                           ;#!Ground all rows at once
		MOV 	A,P1							;#!Read all colums 
		ANL 	A,#00001111B					;#!Masked unused bits
		CJNE 	A,#00001111B,K1                 ;#!Till all keys release
K2: 	LCALL 	DELAY                          	;#!Call 20 msec delay
		MOV 	A,P1                            ;#!See if any key is pressed
		ANL 	A,#00001111B                    ;#!Mask unused bits
		CJNE 	A,#00001111B,OVER               ;#!Key pressed, find row
		SJMP 	K2                              ;#!Check till key pressed
OVER: 	LCALL 	DELAY                         	;#!Wait 20 msec debounce time
		MOV 	A,P1                            ;#!Check key closure
		ANL 	A,#00001111B                    ;#!Mask unused bits
		CJNE 	A,#00001111B,OVER1              ;#!Key pressed, find row
		SJMP 	K2                            	;#!If none, keep polling
OVER1: 	MOV 	P3,#11111110B                 	;#!Ground row 0
		MOV 	A,P1                            ;#!Read all columns
		ANL 	A,#00001111B                    ;#!Mask unused bits
		CJNE 	A,#00001111B,ROW_0              ;#!Key row 0, find col.
		MOV 	P3,#11111101B                   ;#!Ground row 1
		MOV 	A,P1                            ;#!Read all columns
		ANL 	A,#00001111B                    ;#!Mask unused bits
		CJNE 	A,#00001111B,ROW_1              ;#!Key row 1, find col.
		MOV 	P3,#11111011B                   ;#!Ground row 2
		MOV 	A,P1                            ;#!Read all columns
		ANL 	A,#00001111B                    ;#!Mask unused bits
		CJNE 	A,#00001111B,ROW_2              ;#!Key row 2, find col.
		MOV 	P3,#11110111B                   ;#!Ground row 3
		MOV 	A,P1                            ;#!Read all columns
		ANL 	A,#00001111B                    ;#!Mask unused bits
		CJNE 	A,#00001111B,ROW_3              ;#!Key row 3, find col.
		LJMP 	K2                              ;#!If none, false input, repeat
ROW_0: 	MOV 	DPTR,#KCODE0                    ;#!Set DPTR=start of row 0
		SJMP 	FIND                            ;#!Find col. Key belongs to
ROW_1: 	MOV 	DPTR,#KCODE1                    ;#!Set DPTR=start of row
		SJMP 	FIND                            ;#!Find col. Key belongs to
ROW_2: 	MOV 	DPTR,#KCODE2                    ;#!Set DPTR=start of row 2
		SJMP 	FIND                            ;#!Find col. Key belongs to
ROW_3: 	MOV 	DPTR,#KCODE3                    ;#!Set DPTR=start of row 3
FIND: 	RRC 	A                               ;#!See if any CY bit low
		JNC 	MATCH                           ;#!If zero, get ASCII code
		INC 	DPTR                            ;#!Point to next col. addr
		SJMP 	FIND                            ;#!Keep searching		
MATCH: 	CLR 	A                               ;#!Set A=0 (match is found)
		MOVC 	A,@A+DPTR                       ;#!Get ASCII from table	
		RET										;#!return	
;--------------------------------------------------------------------------------------------------#!
;-------COMMANDS LOOK-UP TABLE FOR LCD INITIALIZATION
		ORG		300H
MYCOM: 	DB 		38H,0FH,01H,06H,80H,0
MSG1:	DB		"Set time:",0
MSG2:	DB		"Hour(00~12):",0
MSG3:	DB		"Min(00~60):",0
MSG4:	DB		"AM~1 PM~2",0
MSG5:	DB		"Set date:",0
MSG6:	DB		"Day(00~30):",0
MSG7:	DB		"Month(00~12)",0
MSG8:	DB		"Year(00~99):",0
MSG9:	DB		"             "
;-------ASCII LOOK-UP TABLE FOR EACH ROW			
KCODE0: DB 		"1","2","3","/" 				;#!ROW 0
KCODE1: DB 		"4","5","6","*" 				;#!ROW 1
KCODE2: DB 		"7","8","9","-" 				;#!ROW 2
KCODE3: DB 		"*","0","#","+" 				;#!ROW 3
		END	
