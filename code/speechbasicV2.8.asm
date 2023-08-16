; ###############################################################
; #                                                             #
; #  C64 SPEECH-BASIC C64 SOURCE CODE                           #
; #  Version 2.8 (2023.07.04)                                   #
; #  Copyright (c) 2023 Claus Schlereth                         #
; #                                                             #
; #  This version of the source code is under MIT License       #
; #                                                             #
; #  This source code can be found at:                          #
; #  https://github.com/LeshanDaFo/C64-Speech-Basic             #
; #  This source code is bsed on the existing Disk images       #
; #  published by Markt & Technik in 1986 in the                #
; #  German computer magazine "64'er 86/10"                     #
; #                                                             #
; #  SPEECH-BASIC was written by                                #
; #  Kristian Köhntopp & Daniel Diezemann                       #
; #                                                             #
; ###############################################################
;
; History:
; V2.7 =        Initial version
; V2.8 =        corrcted some errors, optimize some parts in the code

; A problem was existing in the BLOAD command, it was not protected from self-overwriting. 
; This is corrected now by adding code to compare the load address with the basic start address and prevent overwriting itself.
;
; errors
; 1. The subroutine 'checkparam', which is used in DIR, DISK, BLOAD and also BSAVE, does not check whether the specified device exists.
; If you enter a device number that does not exist, the computer freezes
; This error is now corrected by adding a routine to "checkparam", to check if the defined device exists
;
; 2. The PAUSE command has a bug, sometimes skipping 255 bytes from the count value
; This error is now corrected
; changed the version from 2.7 to 2.8
; ----------------------------------------------
; - used system addresses ----------------------
; ----------------------------------------------
CBM_REASON      = $A408                 ; check available memory, do out of memory error if no room
CBM_ERROR       = $A437                 ; Error handling
CBM_CLEAR       = $A65E                 ; perform CLR
CMD_OLDLIST     = $A6EF                 ; cont list
CMD_PLOOP1      = $A6F3                 ; print byte
CBM_OLDTOK      = $A724                 ; list of CBM_CMDS
CBM_NEWSTT      = $A7AE
CBM_EXECOLD     = $A7ED
CBM_FUNCOLD     = $AE80
CBM_ISCNTC      = $A82C                 ; basic call check STP
CBM_LINGET      = $A96B                 ; get line number
CBM_STROUT      = $AB1E                 ; print a string on the screen
CBM_OUTSPC      = $AB3B                 ; print a space
CBM_OUTLOC      = $AB47                 ; char output
CBM_FRMNUM      = $AD8A                 ; get numeric paramter to FAC
CBM_FRMEV       = $AD9E                 ; evaluate expression
CBM_CONTEVAL    = $AE83
CBM_CHKCOM      = $AEFD                 ; check for a comma at txtptr
CBM_FRESTR      = $B6A3                 ; evaluate a string
CBM_GETBYT      = $B79E                 ; 8-bit parameter ==> x
CBM_GETADR      = $B7F7                 ; convert the value in fac to an integer, word at $14/$15
CBM_FINLOG      = $BD7E                 ; ADD (A) TO FAC
CBM_INTOUT      = $BDCD                 ; Output Positive Integer in A/X
CBM_INISTP      = $E39D                 ; initialize the stack pointer
CBM_LUKING      = $F5AF                 ; print searchin for 'file name'
CBM_LODING      = $F5D2                 ; print "LOADING", "VERIFYING"
CBM_UNLSN       = $FFAE                 ; send UNLISTEN out IEEE
CBM_LISTN       = $FFB1                 ; send LISTEN out IEEE
CBM_SETLFS      = $FFBA                 ; set file parameters
CBM_SETNAM      = $FFBD                 ; Set file name
CBM_OPEN        = $FFC0                 ; OPEN Vector
CBM_CLOSE       = $FFC3                 ; CLOSE Vector
CBM_CHKIN       = $FFC6                 ; Set input file
CBM_CHKOUT      = $FFC9                 ; Set Output
CBM_CLRCHN      = $FFCC                 ; Restore I/O Vector
CBM_CHRIN       = $FFCF                 ; Input Vector
CBM_CHROUT      = $FFD2                 ; Output Vector
CBM_STOP        = $FFE1                 ; Test STOP Vector
CBM_GETIN       = $FFE4                 ; get character from input device
CBM_JPLOT       = $FFF0                 ; read/set cursor X/Y position

; OS memory (ROM)
CBM_CMDTAB      = $A09E                 ; Befehlstabelle im ROM

; ----------------------------------------------
; - token definations --------------------------
; ----------------------------------------------
CBM_TK_PRINT    = $99                   ; print
CBM_TK_DATA     = $83                   ; data
CBM_TK_REM      = $8F                   ; rem
CBM_TK_ON       = $91                   ; on
CBM_TK_TO       = $A4                   ; to
CBM_TK_MINUS    = $AB                   ; -

OWN_TK_BLOCK    = $D8                   ; block
OWN_TK_FROM     = $E4                   ; from
OWN_TK_SPEED    = $E5                   ; speed
OWN_TK_OFF      = $E6                   ; off

; ----------------------------------------------
; - char definations ---------------------------
; ----------------------------------------------
CHAR_QUOT       = $22                   ; """
CHAR_QMARK      = $3f                   ; " ? "
CHAR_COLON      = $3A                   ; ' : '

; ----------------------------------------------
; - used zero page addresses -------------------
; ----------------------------------------------
; ----------------------- used zero page addresses -----------------------------
CBM_CHRGET      = $0073                 ; get next character
CBM_CHRGOT      = $0079                 ; get last character

CBM_INPUTBUF    = $0200
CBM_KEYBUF      = $0277
CBM_COLOR       = $0286                 ; charcolor

CBM_SHIFTFLAG   = $028d                 ; 1=SHIFT; 2=C=; 4=CTRL
CBM_KBDSCNVEC	= $028F


CBM_ENDCHR      = $08                   ; search char for the end of an expression
CBM_LVFLAG      = $0A                   ; this is the load/verify flag, need 0 to load a program
CBM_COUNT       = $0b 
CBM_TYPFLAG     = $0d
CBM_QFLAG       = $0f                   ; quote-mode: Bit7=1 ==> quote-mode is set
CBM_LINNUM      = $14                   ; used by LINGET
CBM_BSTART      = $2b                   ; actual basic start
CBM_VARTAB      = $2d                   ; start of variable, also basic end
CBM_MEMSIZ      = $37                   ; highest BASIC RAM address / bottom of string stack
pnt2            = $49
CBM_PNT         = $71
CBM_TXTPTR      = $7A                   ; pointer to actual text position
CBM_STATUS      = $90                   ; Bit6=1 ==> End of File! Bit7=1 ==> Device not present

CBM_FNLEN       = $b7                   ; length of current filename
CBM_CURDEV      = $ba                   ; current device number


;AE/AF                                  ; pointer to program end for LOAD / SAVE
;C1/C2                                  ; start address for LOAD 
;C3/C4                                  ; end address for LOAD

; ----------------------------------------------
; - vector table addresses ---------------------
; ----------------------------------------------


; ----------------------------------------------
; - error message codes ------------------------
; ----------------------------------------------
FILE_NOT_FOUND          = $04
DEVICE_NOT_PRESENT      = $05
MISSING_FILE_NAME       = $08
ILLEGAL_DEVICE_NUMBER   = $09
SYNTAX                  = $0b
ILLEGAL_QUANTITY        = $0e
STRING_TO_LONG          = $17


; ----------------------- program start ----------------------------------------
;-------|---|---|-----------------------|---------------------------------------

!to "build/speechbasicV2.8.prg",cbm
; ----------------------------------------------
; - the basic loader ---------------------------
; ----------------------------------------------
*=$0801
; basic header

    !by $1E,$08,$C2,$07,$9E,$28,$32,$30 ;.....(20
    !by $38,$30,$29,$20,$53,$50,$45,$45 ;  80) SPEE
    !by $43,$48,$20,$42,$41,$53,$49,$43 ;  CH BASIC
    !by $20,$32,$2E,$38,$00,$00,$00     ;  2.8

; program start
        JMP OWN_INIT
; ----------------------------------------------
; - $0823 OWN_CRUNCH ---------------------------
; ----------------------------------------------
OWN_CRUNCH
        LDX CBM_TXTPTR                  ; pointer to first char
        LDY #$04                        ; pointer to line
        STY CBM_QFLAG                   ; delete flag 
.nextchar
        LDA CBM_INPUTBUF,X              ; read a char from the buffer
        BPL .normal                     ; branch if it is not a token
        CMP #$ff                        ; token for 'pi'?
        BEQ .takchar                    ; yes, take it as it is
        INX                             ; else ignore the char
        BNE .nextchar                   ; get the next char   
.normal
        CMP #$20                        ; do we have a space ?
        BEQ .takchar                    ; yes, take it as it is
;----------------------
        STA CBM_ENDCHR                  ; remember the char
;----------------------
        CMP #CHAR_QUOT                  ; is it a quote ?
        BEQ .getchar                    ; yes, take it and go to read a string
        BIT CBM_QFLAG                   ; data mode?
        BVS .takchar                    ; yes, take it as it is
        CMP #CHAR_QMARK                 ; qestion mark?
        BNE .skip                       ; no, then skip it
        LDA #CBM_TK_PRINT               ; else replace it with the print token
        BNE .takchar                    ; take over (jmp)
.skip
        CMP #"0"                        ; less then "0"? $30
        BCC .skip1                      ; yes, skip1
        CMP #"<"                        ; < "<"? $3c
        BCC .takchar                    ; yes, take it as it is
; chars from "0" to ";" are accepted 
.skip1
        STY CBM_PNT                     ; remember the write pointer
        LDY #$4C                        ; preload with token offset
        STY CBM_COUNT                   ; set as counter
        LDY #$FF                        ; preset index
        STX CBM_TXTPTR                  ; remember pointer
        DEX
.cmploop
        INY                             ; next char in table
        INX                             ; next char in buffer
.testnext
        LDA CBM_INPUTBUF,X              ; get char
        SEC
        SBC OWN_CMDS,Y                  ; compare
        BEQ .cmploop                    ; equal, then compare next
        CMP #$80                        ; compare if we have found the last (shifted) char of a command
        BNE .nextcmd                    ; if not, branch to check for a next command from the table

        ORA CBM_COUNT                   ; else make a token, $80 + command number
.takchar1
        LDY CBM_PNT                     ; get back the write pointer
.takchar
        INY                             ; increment y
        INX                             ; increment x 
        STA CBM_INPUTBUF-5,y            ; save the char
        CMP #$00
        BEQ .end                        ; if it was zero, goto end
        SEC                             ; 
        SBC #CHAR_COLON                 ; compare with colon
        BEQ .skip2                      ; yes, clear the data/quote-mode
        CMP #(CBM_TK_DATA-CHAR_COLON)   ; data?
        BNE .skip3                      ; no, check for REM
.skip2
        STA CBM_QFLAG                   ; adjust data/quote-mode
.skip3
        SEC
        SBC #(CBM_TK_REM-CHAR_COLON)    ; rem?
        BNE .nextchar                   ; no, goto get the next char
        STA CBM_ENDCHR                  ; else, remember it
.remloop
        LDA CBM_INPUTBUF,X              ; get a char
        BEQ .takchar                    ; line end?
        CMP CBM_ENDCHR                  ; last char?
        BEQ .takchar                    ; take over
.getchar
        INY
        STA CBM_INPUTBUF-5,Y            ; save the code
        INX
        BNE .remloop                    ; (jmp)
.nextcmd
        LDX CBM_TXTPTR                  ; load the pointer
        INC CBM_COUNT                   ; increment the command counter
.next
        INY
        LDA OWN_CMDS-1,Y                ; load the next char
        BPL .next                       ; command is not finished
        LDA OWN_CMDS,Y
        BNE .testnext                   ; test the next command
        BEQ .oldtoken                   ; else check the old commands
.notfound
        LDA CBM_INPUTBUF,X              ; load a char
        BPL .takchar1                   ; branch if it is not zero
.end
        STA CBM_INPUTBUF-3,Y            ; store zero to the end
        DEC CBM_TXTPTR+1                ; set the text pointer
        LDA #$ff                        ; to
        STA CBM_TXTPTR                  ; $01FF
        RTS
; continue with old token check
.oldtoken
        LDY #$00                        ; index
        STY CBM_COUNT                   ; reset the counter
        LDA OWN_CMDS,Y                  ; load a char from cmd table
        BNE .oldtest
.oldcmp 
        INY
        INX
.oldtest
        LDA CBM_INPUTBUF,X              ; get a char
        SEC
        SBC CBM_CMDTAB,Y                ; compare with a command char
        BEQ .oldcmp                     ; if equal, then go on compare the next char
        CMP #$80                        ; if it was the last (shifted) char of a command
        BNE .nextold                    ; no, go and check the next command
        ORA CBM_COUNT                   ; else make a token, $80 + command number

        BNE .takchar1                   ; else take as it is
.nextold
        LDX CBM_TXTPTR                  ; load the pointer
        INC CBM_COUNT                   ; increment the command counter
.next1
        INY
        LDA CBM_CMDTAB-1,Y              ; load the next char
        BPL .next1                      ; command not finished
        LDA CBM_CMDTAB,Y                ;
        BNE .oldtest                    ; test the next command
        BEQ .notfound                   ; (jmp)

; ----------------------------------------------
; - $08E9 OWN_PLOOP ----------------------------
; ----------------------------------------------
OWN_PLOOP
        PHA
-       LDA CBM_SHIFTFLAG
        CMP #$01
        BEQ -
        PLA

        BPL .out                        ; branch if it is not a token
        BIT CBM_QFLAG                   ; check for quote mode
        BMI .out                        ; yes, print it
        CMP #$ff                        ; is it pi ?
        BEQ .out                        ; yes, print it
        CMP #$cc                        ; compare with a new command
        BCS .toknew                     ; yes, go list the new token
        JMP CBM_OLDTOK                  ; else go list the old token
.out
        JMP CMD_PLOOP1                  ; output a byte        
.toknew
        SEC
        SBC #$CB                        ; sub offset
        TAX                             ; command number
        STY pnt2                        ; remember y
        LDY #$FF                        ; prepare y

--      DEX                             ; command number -1
        BEQ .found                      ; if it is zero, (have a command)
-       INY                             ; else
        LDA OWN_CMDS,Y                  ; skip the rest of
        BPL -                           ; the actual command word
        BMI --                          ; jump next
.found
        INY
        LDA OWN_CMDS,Y                  ; get a char from the table
        BMI +                           ; last ?
        JSR CBM_OUTLOC                  ; no, then print it
        BNE .found                      ; (jmp)
+       JMP CMD_OLDLIST

; ----------------------------------------------
; - $0927 OWN_GONE -----------------------------
; ----------------------------------------------
OWN_GONE
        JSR CBM_CHRGET
        JSR .testcmd
        JMP CBM_NEWSTT                  ; go do interpreter inner loop
.testcmd
---------------------------------
        CMP #$CC                        ; smaller then new commands?
        BCC .oldcmd                     ; yes, goto old command
        CMP #$E4                        ; last new executable command + 1?
        BCC .oknew
.oldcmd
        JSR CBM_CHRGOT
        JMP CBM_EXECOLD
---------------------------------
.oknew
        SEC
        SBC #$CC
        ASL
        TAX
        LDA CMDS_TAB+1,X
        PHA
        LDA CMDS_TAB,X
        PHA
        JMP CBM_CHRGET

; ----------------------------------------------
; - $094E OWN_EVAL -----------------------------
; ----------------------------------------------
OWN_EVAL
        LDA #$00
        STA CBM_TYPFLAG                 ; set numeric
        JSR CBM_CHRGET                  ; get the next char
        CMP #$24                        ; '$'
        BEQ .convhex                    ; handle convert hex
        CMP #$25                        ; '%'
        BEQ .convbin                    ; handle convert bin
        JSR CBM_CHRGOT                  ; get back the last input
        JMP CBM_CONTEVAL+10             ; continue in CBM_EVAL

; ----------------------------------------------
; - $0963 converthex ---------------------------
; ----------------------------------------------
.convhex
        JSR .clearfac                   ; clear the FAC buffer
-       JSR CBM_CHRGET
        BCC .was_digit                  ; if it was a digit
        CMP #$41                        ; else compare with 'A'
        BCC .endconv                    ; if less then exit
        CMP #$47                        ; else compare with 'F'
        BCS .endconv                    ; exit if it is higher
        SEC
        SBC #$07                        ; adjust it to $3A - $3F
; now we have a value between $30 and $3F
.was_digit
        SEC
        SBC #$30                        ; substract #30
        PHA                             ; save the value
        LDA $61                         ; get the FAC1 exponent
        BEQ +                           ; branch if we have the first number
                                        ; and skip increment the exponent
        CLC                             ; else
        ADC #$04                        ; add 4 to the exponent
        BCS .o_f_error
        STA $61                         ; store the FAC1 exponent
+       PLA                             ; get the input back
        BEQ -                           ; branch if it is zero, get the next input
        JSR CBM_FINLOG                  ; else ADD (A) TO FAC
        JMP -                           ; get next
---------------------------------
.endconv
       JMP CBM_CHRGOT
---------------------------------
.o_f_error
        JMP $B97E                       ; overflow error
---------------------------------
; clear FAC #1 buffer
;    $61        FAC #1: Exponent
;    $62-$65    FAC #1: Mantissa
;    $66        FAC #1: Prefix
; LDX $05, STA $61,x should be enough
.clearfac
        LDA #$00
        LDX #$0A
-       STA $5D,X
        DEX
        BPL -
        RTS

; ----------------------------------------------
; - $099E convertbin ---------------------------
; ----------------------------------------------
.convbin
        JSR .clearfac
-       JSR CBM_CHRGET                  ; get achar
        CMP #$32                        ; check if it is above '1'
        BCS .endconv                    ; yes, then end
        CMP #$30                        ; check if it is below '0'
        BCC .endconv                    ; yes, then end
        SBC #$30                        ; else sub. #$30
        PHA                             ; and save it
        LDA $61                         ; get the FAC1 exponent
        BEQ +                           ; branch if it is zero
        INC $61                         ; else increment the exponent
        BEQ .o_f_error                  ; branch if we have an overflow
+       PLA                             ; get the char back
        BEQ -                           ; branch if it is zero
        JSR CBM_FINLOG                  ; else ADD (A) TO FAC
        JMP -                           ; next

; ----------------------------------------------
; - $09C0 OWN_INIT -----------------------------
; ----------------------------------------------
OWN_INIT
; prepare the new basic start
; set a fixed address to $1801
        LDA #$01
        LDY #$18
        STA $2B
        STY $2C
        LDA #$00
        STA $1800

        JSR setvectors
        JMP PRNT_PWRONMSG
; ----------------------------------------------
; - $09D3 setvectors ---------------------------
; ----------------------------------------------
setvectors
; $0304/05 Vector: Tokenize BASIC Text
        LDA #<OWN_CRUNCH 
        STA $0304
        LDA #>OWN_CRUNCH
        STA $0305

; $0306/07 Vector: BASIC Text LIST
        LDA #<OWN_PLOOP
        STA $0306
        LDA #>OWN_PLOOP
        STA $0307

; $0308/09 Vector: BASIC Char. Dispatch
        LDA #<OWN_GONE
        STA $0308
        LDA #>OWN_GONE
        STA $0309

; $030A/0B Vector: BASIC Token Evaluation
        LDA #<OWN_EVAL
        STA $030A
        LDA #>OWN_EVAL
        STA $030B

; $028F/90 Vector: Keyboard scan
        LDA #<OWN_KBDDEC
        STA $028F
        LDA #>OWN_KBDDEC
        STA $0290

; $0318/19 Vektor: (NMI)
        LDA #<OWN_NMI
        STA $0318
        LDA #>OWN_NMI
        STA $0319

; $0316/17 Vektor: BRK-Interrupt
        LDA #<OWN_BRK
        STA $0316
        LDA #>OWN_BRK
        STA $0317

        LDA #$0F
        STA $0289
        RTS
; ----------------------------------------------
; - $0A1F PRNT_PWRONMSG ------------------------
; ----------------------------------------------
PRNT_PWRONMSG
        LDA CBM_BSTART
        LDY CBM_BSTART+1
        JSR CBM_REASON                  ; check the available memory, do out of memory error if there is no space
        LDA #<OWN_PWRONMSG              ; pointer low byte own power-on message
        LDY #>OWN_PWRONMSG              ; pointer high byte own power-on message
        JSR CBM_STROUT                  ; print a string on the screen
        LDA #$98                        ; pointer low byte cbm power-on message
        LDY #$E4                        ; pointer high byte cbm power-on message
        JSR $E42D                       ; print the second part of the C64 power-on message
        JMP CBM_INISTP                  ; initialize the stack pointer
---------------------------------
; ----------------------------------------------
; - $0A37 OWN_MSG ------------------------------
; ----------------------------------------------
OWN_PWRONMSG
        !by $93,$08,$0e,$0d
        !pet "    **** C64 Speech System v2.8 ****"
        !by $00
---------------------------------
OWN_CMDS
        !pet "reseT"                    ; $cc
        !pet "basiC"                    ; $cd
        !pet "helP"                     ; $ce
        !pet "keY"                      ; $cf
        !pet "himeM"                    ; $d0
        !pet "disK"                     ; $d1
        !pet "diR"                      ; $d2
        !pet "bloaD"                    ; $d3
        !pet "bsavE"                    ; $d4
        !pet "maP"                      ; $d5
        !pet "meM"                      ; $d6
        !pet "pausE"                    ; $d7
        !pet "blocK"                    ; $d8
        !pet "heaR"                     ; $d9
        !pet "recorD"                   ; $da
        !pet "plaY"                     ; $db
        !pet "voldeF"                   ; $dc
        !pet "coldeF"                   ; $dd
        !pet "heX"                      ; $de
        !pet "deZ"                      ; $df
        !pet "screeN"                   ; $e0
        !pet "exeC"                     ; $e1
        !pet "moN"                      ; $e2
        !by $DF     ; arrow left        ; $e3
; The following commands are new commands which can only be used together with other commands.
        !pet "froM"                     ; $e4
        !pet "speeD"                    ; $e5
        !pet "ofF"                      ; $e6

        !by $00
---------------------------------
CMDS_TAB
        !word CMD_RESET-1
        !word CMD_BASIC-1
        !word CMD_HELP-1
        !word CMD_KEY-1
        !word CMD_HIMEM-1
        !word CMD_DISK-1
        !word CMD_DIR-1
        !word CMD_BLOAD-1
        !word CMD_BSAVE-1
        !word CMD_MAP-1
        !word CMD_MEM-1
        !word CMD_PAUSE-1
        !word CMD_BLOCK-1
        !word CMD_HEAR-1
        !word CMD_RECORD-1
        !word CMD_PLAY-1
        !word CMD_VOLDEF-1
        !word CMD_COLDEF-1
        !word CMD_HEX-1
        !word CMD_DEZ-1
        !word CMD_SCREEN-1
        !word CMD_EXEC-1
        !word CMD_MON-1
        !word CMD_LEFTARROW-1

; ----------------------------------------------
; - $0B02 RESET --------------------------------
; ----------------------------------------------
; clears the register of the sound chip, video controller, and CIAs.
; In addition, the vector table of the kernel (from $0300) is reassigned.

CMD_RESET
        LDA #$04
        STA $0288
        JSR $FF5B
        JSR $FD15
        JSR $E453
        JSR setvectors
        LDA #$08
        JSR CBM_CHROUT                  ; Output Vector
        LDA #$0E
        JSR CBM_CHROUT                  ; Output Vector
        LDA #$00
        LDX #$18                        ; index
-       STA $D400,X
        DEX
        BPL -
        RTS

; ----------------------------------------------
; - $0B28 BASIC --------------------------------
; ----------------------------------------------
; switch off SPEECH-BASIC

CMD_BASIC
        BIT $9D
        BPL +
        LDA #<.sure_txt
        LDY #>.sure_txt
        JSR CBM_STROUT                  ; print a string on the screen
        JSR CBM_CHRIN                   ; Input Vector
        AND #$7F
        CMP #$59                        ; compare with 'Y'
        PHP                             ; save the status
-       JSR CBM_CHRIN                   ; Input Vector
        CMP #$0D                        ; wait for the return key
        BNE -                           ; loop
        PLP                             ; get the status back
        BNE ++                          ; branch if it was not 'Y'
+       JSR $FD15                       ; else
        JSR $E453                       ; go to
        JSR $E518                       ; basic
++      RTS
---------------------------------
.sure_txt
        !pet "are you sure? ",$00

; ----------------------------------------------
; - $0B5E HELP ---------------------------------
; ----------------------------------------------
; shows all available SPEEC-BASIC commands
; HELP* shows the normal basic commands overview
CMD_HELP
        BNE +                           ; branch if there was any char behind the command
; else prepare to print the speech basic command overview
        LDA #<OWN_CMDS
        STA $A6
        LDA #>OWN_CMDS
        STA $A7
        JMP ++                          ; go to print the commands

; prepare to print the normal basic command overview
+       LDA #<CBM_CMDTAB                
        STA $A6
        LDA #>CBM_CMDTAB
        STA $A7
.loop1
        JSR CBM_CHRGET                  ; delete the next char, to avoid a syntax error
        BNE .loop1                      ; loop if there are more to delete

; print commands overview
++      LDY #$00                        ; index
--      LDA ($A6),Y                     ; load a char from the table
        BEQ ++                          ; branch if it was the end of the table (RTS)
        PHA                             ; else save the char
        AND #$7F                        ; delete bit 7
        JSR CBM_CHROUT                  ; ouput
        INY                             ; increment index
        PLA                             ; return the original char
        BPL --                          ; branch if it was not the last char of a command

        STY $A8                         ; else, temp. save index
; changed to LDA $D3
        LDA $D3
        ;SEC                             ; set the carry for 
        ;JSR CBM_JPLOT                   ; read the cursor position in current logical line
        ;TYA                             ; 
; fill the command string with spaces to get 10 chars
        SEC
-       SBC #$0A                        ; substract 10 from the cursor position
        BCS -                           ; repeat it until we have a minus value
        EOR #$FF                        ; now we have the 10, minus char length
        ADC #$01                        ; add one the get the amount of spaces to print
; ADC #$02 could save the following INX
        TAX                             ; transfere to x
        INX                             ; increment for next decrement only
-       DEX                             ; decrement the space counter
        BNE +                           ; branch if it was not the last space to print
        LDY $A8                         ; else, get back the saved index
        JMP --                          ; go, do the next command string
---------------------------------
+       JSR CBM_OUTSPC                  ; print a space
        BNE -                           ; loop
++      RTS

; ----------------------------------------------
; - $0BA6 KEY ----------------------------------
; ----------------------------------------------
; edit or show the function keys
CMD_KEY
        BNE .keynew                     ; if there is an input
; else show keys
        LDA #$00
.loop   PHA
        JSR set_pointer                 ; calc and set pointer
        LDX #$00                        ; pointer to txt
        JSR txtout                      ; print "key"
        PLA                             ; 0 to 7 (loop)
        PHA
        TAX                             ;
        INX                             ; 1 to 8
        LDA #$00                        ;
        JSR CBM_INTOUT                  ; output key number
        LDX #$05                        ; pointer        
        JSR txtout                      ; print ',"'
        LDA $A6                         ; keytab low byte
        LDY $A7                         ; keytab high byte
        JSR prntkey                     ; output a key string
        LDX #$08                        ; pointer to txt
        JSR txtout                      ; print quote+return
        PLA                             ;
        TAX                             ;
        INX                             ; next key
        TXA
        CMP #$08                        ; compare
        BNE .loop                       ; not finished, go do next
        RTS
---------------------------------
.keynew 
        JSR CBM_GETBYT                  ; 8-bit parameter ==> x
        DEX                             ; decrement
        BPL +                           ; branch on plus

illqu_error
        LDX #ILLEGAL_QUANTITY
        JMP CBM_ERROR                   ; Error handling
---------------------------------
+       CPX #$08                        ; 
        BCS illqu_error                 ; 8 or higher, error
        TXA                             ; put into accu
        JSR set_pointer                 ; calculate and set pointer
        JSR CBM_CHKCOM                  ; check for comma at txtptr
        JSR CBM_FRMEV                   ; evaluate expression
        JSR CBM_FRESTR                  ; evaluate string
        CMP #$10                        ; max length
        BCC .dokey                      ; branch if ok
string_error
        LDX #STRING_TO_LONG             ; else do error
        JMP CBM_ERROR                   ; Error handling
---------------------------------
.dokey  TAY                             ; set index
        LDA #$00                        ;
        BEQ +                           ; (jmp) set 0 to the end
-       LDA ($22),Y                     ; load input char
        CMP #$5F                        ; compare with arrow left
        BNE +                           ; branch if not
        LDA #$0D                        ; else exchange with return
+       STA ($A6),Y                     ; store it in table
        DEY                             ; decrement index
        BPL -                           ; branch do next
        RTS                             ; else finish
---------------------------------
set_pointer
        ASL                             ;
        ASL                             ; multiply by
        ASL                             ; 16
        ASL                             ;
        CLC
        ADC #<keytab                    ; add with keytab address low byte
        STA $A6                         ; save as pointer low
        LDA #>keytab                    ;
        ADC #$00                        ;
        STA $A7                         ; save pointer high
        RTS
---------------------------------
; used from BLOAD, and BSAVE
; check for direct mode, to output text or not
chkdirect
        BIT $9D                         ; check direct mode
        BMI txtout                      ; branch if
        RTS                             ; else return, (no text output in program mode)
---------------------------------
; theese parts (L0C23 and L0C2F) are some common used parts
txtout  LDA msgtxt,X
        BEQ +
        JSR CBM_CHROUT                  ; output
        INX
        BNE txtout
+       RTS
---------------------------------
prntret
        LDA #$0D
        JMP CBM_CHROUT                  ; output
---------------------------------
prntkey
        STA $A6                         ; keytab low byte
        STY $A7                         ; keytab high byte
        LDY #$00                        ; index
-       LDA ($A6),Y                     ; load char from keytab
        BEQ ++                          ; branch if it was the last
        PHA                             ; tmp save char
        AND #$7F                        ; clear bit 7
        CMP #$0D                        ; compare with return
        BNE +                           ; branch if not
        PLA                             ; get tmp char
        LDA #$5F                        ; load arrow left
        !by $24                         ; skip next pla
+       PLA
        JSR CBM_CHROUT                  ; print char
        INY                             ; increment index
        BNE -                           ; if not zero, do next
++      RTS                             ; finished
---------------------------------
msgtxt
        !pet "key ",$00 
        !pet $2C,$22,$00
        !pet $22,$0D,$00
        !pet "block ",$00
        !pet " from ",$00
        !pet " to ",$00

keytab
        !pet $93,"run",$0d,$00,"          "
        !pet $93,"list",$0d,$00,"         "
        !pet "play ",$00,"          "
        !pet "hear:record ",$00,"   "
        !pet $93,"help",$0d,"key",$0d,$00,"     "
        !pet "block ",$00,"         "
        !pet $93,"dir",$0d,$00,"          "
        !pet "disk",$0d,$00,"          "

keynum !by $00,$02,$04,$06,$01,$03,$05,$07
; ----------------------------------------------
; - $0CF7 OWN_KBDDEC ---------------------------
; ----------------------------------------------
OWN_KBDDEC
        JSR $EB48                       ; SHFLOG evaluate the SHIFT/CTRL/C= keys
        LDY $C6                         ; Number of characters in keyboard buffer
        DEY
        SEC
        LDA CBM_KEYBUF,Y                ; load from input buffer
        SBC #$85                        ; F-key starts at $85
        BCS +                           ; branch if we have maybe an f-key
-       RTS                             ; else return
---------------------------------
+       CMP #$08                        ; compare with max f-key number
        BCS -                           ; branch, go back if higher
        TAY                             ; index
        LDA $A6                         ; temp. save A6
        PHA
        LDA $A7                         ; temp. save A7
        PHA
        LDA keynum,Y                    ; load the f-key number
        JSR set_pointer                 ; set pointer to f-key string
        LDY #$00                        ; index
        LDX $C6                         ; load buffer amount
        DEX                             ; decrement by 1
-       LDA ($A6),Y                     ; load f-key char
        BEQ +                           ; branch if it was zero
        STA CBM_KEYBUF,X                ; store value to buffer
        INY                             ; point to next place in buffer
        INX                             ; increment
        CPX #$0F
        BNE -
+       STX $C6
        PLA                             ; restore
        STA $A7                         ; a7
        PLA
        STA $A6                         ; a6
        RTS
; ----------------------------------------------
; - $0D32 OWN_IRQ ------------------------------
; ----------------------------------------------
; changed IRQ, used in PAUSE
OWN_IRQ 
        CLC
        LDA timer
        ADC timer+1
        BNE +                           ; if not zero go dec. timer
        BCC ++                          ; else go normal IRQ

+       SEC                             
        LDA timer
        SBC #$01                        ; decrement timer
        STA timer                       ;
        LDA timer+1                     ;
        SBC #$00                        ;
        STA timer+1                     ;
++      JMP $EA31                       ; go do normal IRQ
; ----------------------------------------------
; - $0D51 OWN_NMI ------------------------------
; ----------------------------------------------
OWN_NMI
        PHA
        TXA
        PHA
        TYA
        PHA
        JSR $F6BC
        JSR CBM_STOP                    ; Test STOP Vector
        BEQ +
        JMP $FE72
; ----------------------------------------------
; - $0D61 OWN_BRK ------------------------------
; ----------------------------------------------
OWN_BRK
+       LDA #$7F
        JSR CBM_CLOSE                   ; CLOSE Vector
        JSR $FD15
        JSR $FDA3
        JSR CMD_RESET
        JMP ($A002)

; ----------------------------------------------
; - $0D72 HIMEM --------------------------------
; ----------------------------------------------
; defines the end of basic (start of the data area)
; If the insert 16 bit value is higher then $A000,
; or below the program end, an illegal quantity error is displayed
CMD_HIMEM
        JSR GETADDR                     ; get address
        CMP #$A0                        ; compare high byte
        BEQ +                           ; go compare low byte
        BCC ++                          ; go if less the $A000
-       JMP illqu_error                 ; else illegal quantity error
---------------------------------
+       CPX #$00                        ; if high byte was $A0, compare low byte
        BNE -                           ; error, if above $A000
++      CMP CBM_VARTAB+1                ; compare with high byte programm end
        BCC -                           ; error, if less
        BEQ +                           ; if equal, go compare low byte
        JMP ++                          ; else store it as new HIMEM address
---------------------------------
+       CPX CBM_VARTAB                  ; compare with progamm end
        BCC -                           ; do error if below
; store new HIMEM address
++      STX CBM_MEMSIZ                  ; store low byte
        STA CBM_MEMSIZ+1                ; store high byte
        LDA #$00                        ;
        JMP CBM_CLEAR                   ; perform CLR

; ----------------------------------------------
; - $0D98 DISK ---------------------------------
; ----------------------------------------------
; read the disk error channel, or send a disc-command
CMD_DISK
;        LDA #$00
; set file name is not necessary here, it is called in chkparam again
;        JSR CBM_SETNAM                  ; Set file name
        LDA #$7F                        ; file number
        LDX #$08                        ; device number
        LDY #$0F                        ; channel
        JSR CBM_SETLFS                  ; set file parameters
        JSR chkparam                    ; check for name and a following device number
        JSR CBM_OPEN                    ; OPEN Vector
        LDA CBM_FNLEN                   ;
        BNE +                           ; if there was an input, go wait and close
; read error channel
        LDX #$7F                        ; file number
        JSR CBM_CHKIN                   ; set input file
-       JSR CBM_GETIN                   ; read char
        CMP #$0D                        ; compare with return
        BEQ +                           ; branch if it was the last
        JSR CBM_CHROUT                  ; print char to screen
        JMP -                           ; loop
---------------------------------
+       JSR CBM_CLRCHN                  ; Restore I/O Vector
        LDA #$7F
        JSR CBM_CLOSE                   ; CLOSE Vector
        RTS

; check for a following name and a device number
; checkparam does not check whether the specified device exists
chkparam                             
        JSR $E206                       ; test if "end of line", if so end here
        JSR $E257                       ; set up given filename and perform SETNAM
        JSR $E206                       ; test if "end of line", if so end here
        JSR $E200                       ; look for comma, and input one byte, FA, to (X)
        CPX #$08                        ; check for device number 8
        BCC +                           ; branch if smaller then 8
        STX CBM_CURDEV                  ; store as current device number
; ------------------------------------------------------------------------------
; ----------------- check if a drive is existing -------------------------------
; ------------------------------------------------------------------------------
G_CHKEXIST:	
        LDA #$00
	STA CBM_STATUS
	LDA CBM_CURDEV
	JSR CBM_LISTN                   ; LISTEN
	JSR CBM_UNLSN                   ; UNLISTEN
	LDA CBM_STATUS                  ; what happened?
	BMI .g_derror
        RTS
.g_derror
        LDX CBM_CURDEV
        JSR .close
        LDX #DEVICE_NOT_PRESENT
        !by $2c
+       LDX #ILLEGAL_DEVICE_NUMBER      ; do illegal device error
        JMP CBM_ERROR                   ; X contains BASIC error code

; ----------------------------------------------
; - $0DE3 DIR ----------------------------------
; ----------------------------------------------
; shows the content of the attached disc
CMD_DIR
; set "$" as standard name
        LDA #$01                        ; file name length
        LDX #$A6                        ; address low byte
        LDY #$00                        ; address high byte
        JSR CBM_SETNAM                  ; Set file name ('$')

        LDA #$7F                        ; file number
        LDX #$08                        ; device number
        LDY #$00                        ; channel
        JSR CBM_SETLFS                  ; set file parameters
        LDA #$24                        ; "$"
        STA $A6
        JSR chkparam                    ; check for name and a following device number
        LDA #$00                        ;
        STA CBM_STATUS                  ;
        JSR CBM_OPEN                    ; OPEN Vector
        LDX #$7F
        JSR CBM_CHKIN                   ; Set input file
; first time skip 4 bytes
        JSR rd2char                     ; read 2 bytes
--      JSR rd2char                     ; read 2 bytes
        JSR rd2char                     ; read 2 bytes
        JSR CBM_INTOUT                  ; Output Positive Integer in A/X
        LDA #$20
        JSR CBM_CHROUT                  ; output
-       JSR CBM_GETIN                   ; read char
        LDX CBM_STATUS                  ; check status
        BNE .close                      ; branch to close
        JSR CBM_CHROUT                  ; else output to screen
        BNE -                           ; have more to read
-       LDA CBM_SHIFTFLAG
        CMP #$01                        ; check ctrl key
        BEQ -                           ; wait until released
        CMP #$02                        ; check commodore key
        BEQ .close                      ; branch to close
        JSR prntret                     ; else print return
        JMP --                          ; next line
---------------------------------
; - $0E36 close
.close
        JSR CBM_CLRCHN                  ; Restore I/O Vector
        LDA #$7F
        JSR CBM_CLOSE                   ; CLOSE Vector
        RTS
---------------------------------
; - $0E3F
rd2char
        JSR CBM_GETIN                   ; read char
rd1char
        TAX                             ; transfer to x
        JSR CBM_GETIN                   ; read char
        LDY CBM_STATUS                  ; check status
        BEQ +                           ; branch if ok
        PLA                             ; else remove last jsr information
        PLA
        JMP .close                      ; jmp to close
---------------------------------
+       RTS

; ----------------------------------------------
; - $0E50 BLOAD --------------------------------
; ----------------------------------------------
; loads an program from the attached disc, to the original or an optional defined memory location
; also the length of data to read can be defined by input the end address as a parameter as BLOCK, or addresses
CMD_BLOAD
        LDA #$00                        ;
        STA CBM_LVFLAG                  ; set load flag
        STA CBM_STATUS                  ; delete status
; set file name is not necessary here, it is called in chkparam again
        JSR CBM_SETNAM                  ; Set file name
        LDA #$7F                        ; file number
        LDX #$08                        ; device number
        LDY #$00                        ; channel
        JSR CBM_SETLFS                  ; set file parameters
        JSR chkparam                    ; check for name and a following device number
        LDA CBM_FNLEN                   ; load file name length
        BNE +                           ; branch if it is not zero
L0E69   LDX #MISSING_FILE_NAME          ; else do missing file name error
        JMP CBM_ERROR                   ; Error handling
---------------------------------
+       JSR CBM_LUKING                  ; print "SEARCHING FOR" 'file name'
        JSR CBM_OPEN                    ; OPEN Vector
        LDX #$7F                        ; file number
        JSR CBM_CHKIN                   ; Set input file
        JSR CBM_GETIN                   ; read char from device (start address low byte)
        PHA                             ; save
        LDA CBM_STATUS                  ; read status
        BEQ +                           ; branch if it is ok
        JSR CBM_CLRCHN                  ; else Restore I/O Vector
        LDA #$7F                        ; file number
        JSR CBM_CLOSE                   ; CLOSE Vector
        LDX #FILE_NOT_FOUND             ; print error
        JMP CBM_ERROR                   ; Error handling
---------------------------------
+       JSR CBM_LODING                  ; print "LOADING", "VERIFYING" depending on load/verify flag
        PLA                             ; get back start address low byte
        JSR rd1char                     ; transfer accu to x, read next char from device (start address high byte)
        CLC
; the file was existing and opened, the start address was read from the file
        JSR L0F45                       ; get parameter if available
; start-, and end addresses are set now
        JSR L0F64                       ; transfere end address into $A8/$A9
        LDA $AE
        STA blocktabstart               ; save start address into block 0
        LDA $AF
        STA blocktabstart+1
-       JSR CBM_GETIN                   ; read char
; allways load to RAM
        SEI
        LDY #$34                        ; switch on RAM
        STY $01
        LDY #$00                        ; index
        STA ($AE),Y                     ; save char
        LDY #$37
        STY $01                         ; switch on ROM
        CLI
        INC $AE                         ; increment address low byte
        BNE +                           ; branch if not zero
        INC $AF                         ; else increment address high byte
+       LDY CBM_STATUS                  ; check status
        BNE +                           ; loop
        LDA $AF                         ; load actual address high byte
        CMP $A9                         ; compare with target
        BNE -                           ; loop
        LDA $AE                         ; else compare also the low byte
        CMP $A8
        BNE -                           ; loop if not reached
+       JSR CBM_CLRCHN                  ; else Restore I/O Vector
        LDA #$7F
        JSR CBM_CLOSE                   ; and CLOSE the file
        LDA $AE                         ; load end address low byte
        STA blocktabstart+2             ; save it to block 0
        LDA $AF                         ; high byte
        STA blocktabstart+3             ; save it
L0EDF   LDX #$19                        ; index for message text " to "
        JSR chkdirect                   ; output if in direct mode
L0EE4   LDX $AE                         ; end address low byte
        LDA $AF                         ; end address high byte
        JSR +                           ; print if in direct mode
        RTS
---------------------------------
+       BIT $9D                         ; check direct mode
        BMI printhexordec               ; if yes, can output the address as text
        RTS
---------------------------------
; depending on the HEXDEC_FLAG, the value is output as a hex value or dec value
printhexordec
L0EF1   BIT HEXDEC_FLAG
        BMI +                           ; branch, handle hex
        JMP CBM_INTOUT                  ; else, output a positive integer in A/X as dec
---------------------------------
+       TAY                             ; high byte
        TXA                             ; low byte
        PHA                             ; save low byte
        TYA                             ; high byte
        PHA                             ; save high byte
        LDA #$24                        ; '$'
        JSR CBM_CHROUT                  ; print
        PLA                             ; load high byte
        BEQ +                           ; branch if zero

        JSR ++                          ; else convert a byte
+       PLA                             ; get low byte
; convert a byte to a hex$
++      PHA                             ; save byte
        LSR                             ;
        LSR                             ; shift low nibble
        LSR                             ; to high nibble
        LSR                             ;
        JSR +                           ; output a single hex string value
        PLA                             ; get back the orig. value
        AND #$0F                        ; delete the low nibble

+       TAX                             ; put a value to x as index
        LDA hextable,X                  ; load the corresponding hex string value
        JMP CBM_CHROUT                  ; print

---------------------------------
hextable
        !pet "0123456789abcdef"
--------------------------------- 
; $0f2c is not used anywhere ?
; L0F2C   JSR CBM_CHKCOM                  ; check for a comma at txtptr
; get 16 bit value and check if it is below $FFF9
GETADDR
        JSR CBM_FRMNUM                  ; evaluate an expression and check if it is numeric, else do type a mismatch
        JSR CBM_GETADR                  ; convert the value in fac to an integer, word at $14/$15
        LDX CBM_LINNUM                  ; low byte
        LDA CBM_LINNUM+1                ; high byte
        CMP #$FF                        ; compare with $FFF9
        BNE +
        CPX #$F9
        BCC +
.error1        JMP illqu_error                 ; do an error if it is equal or higher
---------------------------------
+       RTS
---------------------------------
; if we comming from BLOAD, the carry was clear,
; if we comming from BSAVE, the carry was set
L0F45   PHP                             ; save status 'carry-flag'
        JSR set_def_val                 ; handle check parameter, and set start -, end address
        LDA #$12
        PLP                             ; restore status 'carry-flag'
        ADC #$00
        TAX                             ; in x is now either #$12 or #$13 as the msgtext pointer
        JSR chkdirect                   ; if direct mode is set, output text "from" or " from"
; in DATA_START is now either the start address read from the file, or read from the input as BLOCK or normal address input
;        LDX DATA_START                  ; the start address low byte
; correct an error here
; the load address was not verified with program end
        LDA DATA_START+1                ; the start address high byte
        CMP #$18                        ; compare with basic start high byte
        BCC .error                      ; if smaller, then error
        BNE .ok                         ; if higher then ok
        LDX DATA_START                  ; else load x with the start address low byte
        CPX #$01                        ; compare x with basic start low byte 
        BCC .error                      ; error if smaller
; else
.ok
        STX $AE                         ; Pointer to the program end for LOAD / SAVE
        STA $AF
        JSR L0EE4                       ; output the address to the screen if in direct mode 
        LDX $AE                         ; Pointer to the program end for LOAD / SAVE
        LDA $AF
        RTS
.error
        jsr .close
        jmp .error1
---------------------------------
; handle save endaddress into $A8/$A9
L0F64   LDX DATA_END
        LDA DATA_END+1
        STX $A8
        STA $A9
        RTS

; ----------------------------------------------
; - $0F6F BSAVE --------------------------------
; ----------------------------------------------
; saves a memory area to the atached disc
CMD_BSAVE
        LDA #$00
        JSR CBM_SETNAM                  ; Set file name
        LDA #$7F
        LDX #$08
        LDY #$01
        JSR CBM_SETLFS                  ; set the file parameters (a: file#, x: device#, y: 2nd channel)
        JSR chkparam                    ; check for a name and a following device number
        LDA CBM_FNLEN                   ; the file name length
        BNE +                           ; branch if there was an input
        JMP L0E69                       ; else output 'missing file name'
---------------------------------
+       LDA #$00
        STA CBM_STATUS                  ; clear status
        JSR CBM_OPEN                    ; OPEN Vector
        JSR $F68F                       ; print saving <file name>
        JSR prntret                     ; print return
        SEC
        LDX CBM_MEMSIZ                  ; default start low byte
        LDA CBM_MEMSIZ+1                ; default start high byte
        JSR L0F45                       ; get parameter if available
; start-, und end addresses are set now
        JSR L0F64                       ; transfere end address into $A8/$A9
        LDX #$7F
        JSR CBM_CHKOUT                  ; Set Output
        LDA $AE                         ; start address low byte
        JSR CBM_CHROUT                  ; output
        LDA $AF                         ; start address high byte
        JSR CBM_CHROUT                  ; output
; allways saves the RAM
saveloop
        SEI
        LDY #$34
        STY $01                         ; switch on RAM
        LDY #$00                        ; index
        LDA ($AE),Y                     ; get actual char to save
        LDY #$37                        ; switch on ROM
        STY $01
        CLI
        JSR CBM_CHROUT                  ; save the char
        LDA CBM_STATUS                  ; check the status
        BEQ +                           ; branch if it was ok
; the next command is double, it is also called in .close
;        JSR CBM_CLRCHN                  ; Restore I/O Vector
        JMP .close                      ; close the file
---------------------------------
+       INC $AE                         ; increment address low byte
        BNE +                           ; branch if not zero
        INC $AF                         ; else increment address high byte
+       LDA $AF                         ; load high byte
        CMP $A9                         ; compare with target
        BNE saveloop                    ; loop
        LDA $AE                         ; get low byte
        CMP $A8                         ; compare
        BNE saveloop                    ; loop
        JSR CBM_CLRCHN                  ; else Restore I/O Vector
        LDA #$7F
        JSR CBM_CLOSE                   ; CLOSE the file
        JMP L0EDF                       ; output the message ' to <address>' if in direct mode

; ----------------------------------------------
; - $0FE6 MEM ----------------------------------
; ---------------------------------------------- 
; shows the memory status
CMD_MEM
; prepare pointer to mem texts
        LDA #<MEMTXTPTR
        STA $AE
        LDA #>MEMTXTPTR
        STA $AF

L0FEE   LDY #$00                        ; index
        LDA ($AE),Y                     ; load text address pointer low byte
        PHA
        INY
        LDA ($AE),Y                     ; load text address pointer high byte
        TAY
        PLA
        CPY #$FF
        BEQ +
        JSR CBM_STROUT                  ; print a string on the screen
        LDY #$02
        JSR prntaddr                    ; output low address
        LDA #$0D                        ; cursor position in line
        JSR setcursor                   ; set position, used to print dec. value
        LDX #$19                        ; pointer to txt
        JSR txtout                      ; print " to "
        LDY #$04                        ; pointer to high address
        JSR prntaddr                    ; output high address
        JSR prntret
        CLC
        LDA $AE                         ; load mem text pointer low byte
        ADC #$06                        ; add 6, points to next part
        STA $AE                         ; save
        LDA $AF                         ; load high byte
        ADC #$00                        ; increase with carry
        STA $AF                         ; staore back
        JMP L0FEE                       ; do next output
---------------------------------
+       RTS
---------------------------------
; load an address and print it
prntaddr
        LDA ($AE),Y                     ; load address pointer low byte
        STA $A6                         ; store
        INY                             ; increment index
        LDA ($AE),Y                     ; load address pointer high byte
        STA $A7                         ; store
        LDY #$00                        ; load index
        LDA ($A6),Y                     ; load address value low byte
        TAX                             ; transfer to x
        INY                             ; increment index
        LDA ($A6),Y                     ; load address value high byte
        JMP printhexordec               ; print the address on screen (hex or dec)
---------------------------------
MEMTXTPTR
;basic
        !word TXT_BASIC
        !word $002b
        !word $002d
;sound
        !word TXT_SOUND
        !word $0037
        !word L1053
;keys
        !word TXT_KEYS
        !word L1079
        !word L107B
;blocks
        !word TXT_BLOCKS
        !word L107D
        !word L107F

L1053   !word $fff8

TXT_BASIC       !pet "basic : ",$00
TXT_SOUND       !pet "sound : ",$00
TXT_KEYS        !pet "keys  : ",$00
TXT_BLOCKS      !pet "blocks: ",$00

L1079   !word keytab
L107B   !word keynum
L107D   !word blocktabstart
L107F   !word blocktabend

; ----------------------------------------------
; - $1081 PAUSE --------------------------------
; ---------------------------------------------- 
; stops a program for a certain time
CMD_PAUSE
        JSR CBM_CHRGOT                  ; remark: not need here, the last char is still in accu
                                        ; the branch alone should also work
        BEQ +                           ; branch if there is no parameter
exec_pause
        JSR GETADDR                     ; get 16bit value, and check it
        STX timer                       ; set as 'timer' low byte
        STA timer+1                     ; 'timer' high byte
        SEI                             ;
        LDA $0314                       ; save
        PHA                             ; old IRQ
        LDA $0315                       ; vector
        PHA                             ; address
        LDA #<OWN_IRQ                   ;
        STA $0314                       ; save changed
        LDA #>OWN_IRQ                   ; IRQ vector
        STA $0315                       ; address
        CLI                             ;
; a possible error is corrected here, by checking the high byte first.
-       LDA timer+1                     ; compare
        BNE -                           ;
        LDA timer                       ; 'timer'
        BNE -                           ; loop

        SEI                             ; if finished,
        PLA                             ; restore 
        STA $0315                       ; old
        PLA                             ; IRQ
        STA $0314                       ; vector
        CLI                             ;
        RTS                     
---------------------------------
timer   !by $00,$00                     ; placeholder 'timer' low and high byte
---------------------------------
; without parameters, PAUSE waits for a status change at port 2. That means for incoming sample data.
+       NOP
        LDA $DC00
-       CMP $DC00
        BEQ -
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        RTS
; ----------------------------------------------
; - $10CB MAP ----------------------------------
; ---------------------------------------------- 
; outputs the block table in editable form
; it's also used from BLOCK command
CMD_MAP
        PHP                             ; save parameter status
; preload start and end values
        LDA #$00                        ; lowest block number
        STA blk_buff                    ; store in buffer
        LDA #$20                        ; max block amount +1
        STA blk_buff+1                  ; store in buffer

        PLP                             ; get back parameter status
        BEQ ++                          ; if we comming from BLOCK command, or no parameter was insert
; check parameter
        JSR CBM_CHRGOT                  ; get last char
        JSR get_blk_no                  ; get a block number, can be also 00 if there was a minus as the first char
        STA blk_buff                    ; start block number
        STX blk_buff+1                  ; start block +1 as default end block number
        JSR CBM_CHRGOT                  ; check last char
        BEQ ++                          ; branch if there was only one number
        CMP #CBM_TK_MINUS               ; else check for '-' either the first input or the input after a number
        BEQ +
; if there was any faulty input, we go back, and normaly output an syntax error
        RTS
---------------------------------
+       JSR CBM_CHRGET                  ; get next char
        BNE +                           ; branch if not empty
        LDA #$20                        ; max block amount +1
        STA blk_buff+1                  ; the block number +1
        BNE ++                          ; skip get next byte

+       JSR get_blk_no                  ; get end block number
        STX blk_buff+1                  ; end block number +1 

++      LDA blk_buff                    ; start block number

; loop print block strings
blk_loop
        PHA                             ; save actual block number

        JSR CALC_BLKADR                 ; calculate block address
        LDX #$0B                        ; text pointer
        JSR txtout                      ; print "block "
; print block number
        PLA                             ; get actual block number
        PHA                             ; and save it again
        TAX                             ; low byte block number
        LDA #$00                        ; high byte every time zero
        JSR CBM_INTOUT                  ; print block number in A/X
; set cursor
        LDA #$08                        ; position
        JSR setcursor                   ; set position, used to print dec. value
; print ' from'
        LDX #$12                        ; text pointer
        JSR txtout                      ; print " from "
; print 1. address
        LDY #$00                        ; index
        JSR prnt_addr                   ; print address from (AE),y
; set cursor
        LDA #$13                        ; position
        JSR setcursor                   ; set position, used to print dec. value
; print ' to '
        LDX #$19                        ; text pointer
        JSR txtout                      ; print " to "
;print 2. address
        LDY #$02                        ; index
        JSR prnt_addr                   ; print address from (AE),y
; print space
        LDA #$20                        ; 'space'
        JSR CBM_CHROUT                  ; print
; set cursor
        LDA #$1D                        ; position
        JSR setcursor                   ; set position, used to print dec. value
; print string within quotes
        LDA #$22                        ; quote
        JSR CBM_CHROUT                  ; print
        LDY $A8                         ; index
        LDX #$08                        ; counter
-       LDA stringtable,y
        JSR CBM_CHROUT                  ; output
        INY                             ; increment index
        DEX                             ; decrement counter
        BNE -                           ; loop
        LDA #$22                        ; quote
        JSR CBM_CHROUT                  ; print
        JSR prntret                     ; print return
        
        PLA                             ; get back actual block number
        TAX                             ; transfere to X
        JSR CBM_ISCNTC                  ; basic call check STP
        INX                             ; increment block number
        TXA                             ; put back to accu
        CMP blk_buff+1                  ; compare with end block number
        BNE blk_loop                    ; not the end, do next block
        RTS                             ; finished output block map
---------------------------------
; $1165 buffer for map and block
blk_buff
        !by $00,$00
---------------------------------
; sets the cursor position in screen line
; carry clear, set the cursor position column (x), row (y)
; carry set, reads the cuesor position into x,y
setcursor
        PHA
        SEC                             ; flag for read the cursor position
        JSR CBM_JPLOT                   ; read column,row
        PLA                             ; get back target column
        TAY                             ; save as row number
        CLC                             ; flag for set the cursor
        JMP CBM_JPLOT
---------------------------------
; get a byte from input line
get_blk_no
        JSR CBM_LINGET                  ; get block number
        LDA CBM_LINNUM+1                ; check high byte
        BEQ +                           ; branch if zero
        JMP illqu_error                 ; else illegal quantity error
---------------------------------
+       LDA CBM_LINNUM                  ; get low byte
        CMP #$20                        ; compare with max +1
        BCC +                           ; branch if less
        JMP illqu_error                 ; else illegal quantity error
---------------------------------
+       TAX                             ; block number
        INX                             ; increment
        RTS
---------------------------------
; - $1188 print an address
prnt_addr
        LDA ($AE),Y                     ; address pointer low byte
        TAX
        INY
        LDA ($AE),Y                     ; address pointer high byte
        JSR printhexordec
        RTS
---------------------------------
; - $1192 calculate block address, and store it into $AE/$AF
CALC_BLKADR
        ASL                             ;
        ASL                             ; multiply with 4
        PHA                             ; store pointer
        CLC
        ADC #<blocktabstart
        STA $AE
        LDA #>blocktabstart
        ADC #$00
        STA $AF
        PLA                             ; restore saved pointer
        ASL                             ; multiply with 2
        STA $A8                         ; store as 'block string' pointer
        RTS
; ----------------------------------------------
; - $11A5 BLOCK --------------------------------
; ---------------------------------------------- 
CMD_BLOCK
        BNE +                           ; if thwere was any parameter
        JMP CMD_MAP                     ; else show blocks overview
---------------------------------
+       JSR CBM_GETBYT                  ; 8-bit parameter ==> x
        CPX #$00
        BEQ L11B5                       ; illegal quantity
        CPX #$20                        ; max block +1
        BCC +                           ; branch if less
L11B5   JMP illqu_error
---------------------------------
+       TXA                             ; block number
        JSR CALC_BLKADR                 ; calculate the block table pointer and save it into $AE/$AF
        LDA $AE                         ; address low byte
        STA $A6
        LDA $AF                         ; address high byte
        STA $A7
        LDX CBM_MEMSIZ                  ; default start low byte
        LDA CBM_MEMSIZ+1                ; default start high byte
        JSR set_def_val                 ; handle check parameter, and set start -, end address
        LDY #$03                        ; index
-       LDA DATA_START,Y                ; copy start-, end addresses
        STA ($A6),Y                     ; store into buffer
        DEY                             ; dec. index
        BPL -                           ; next address byte
        JSR CBM_CHRGOT                  ; get last char
        BEQ ++                          ; nothing more? rts
; delete actual block name string
        LDY $A8                         ; index
        LDX #$08                        ; length
        LDA #$20                        ; 'space'
-       STA stringtable,Y               ; name
        INY                             ; increment index
        DEX                             ; dec. length counter
        BNE -                           ; next

        JSR CBM_FRMEV                   ; evaluate expression
        JSR CBM_FRESTR                  ; evaluate string
        CMP #$00                        ; compare string length
        BNE +                           ; not empty
        RTS                             ; else return
---------------------------------
+       CMP #$09                        ; compare with max length +1
        BCC +                           ; branch if less
        JMP string_error                ; else print STRING_TO_LONG ERROR
---------------------------------
+       STX $AA                         ; string pointer low byte
        STY $AB                         ; string pointer high byte
        TAY                             ; string length
        DEY                             ; decrement
        TYA                             ; put back into accu
        CLC
        ADC $A8                         ; block name index
        TAX                             ; transfere to x for index
-       LDA ($AA),Y                     ; load char from new insert string
        STA stringtable,X               ; save into block name buffer
        DEX                             ; decrement index
        DEY
        BPL -                           ; not last, do next
++      RTS
---------------------------------
; - $120E set default values
set_def_val
        STX DATA_START                  ; set start low byte
        STA DATA_START+1                ; set start high byte
        LDX #$F8                         
        LDA #$FF
        STX DATA_END                    ; set end low byte
        STA DATA_END+1                  ; set end high byte
; ----------------------------------------------------
; handle parameter
        JSR CBM_CHRGOT                  ; check last input char
        CMP #OWN_TK_BLOCK               ; compare with BLOCK token
        BNE chkfrom                     ; not block, check FROM token
; handle address set from BLOCK input
        JSR CBM_CHRGET                  ; get next input
x_blk   JSR CBM_GETBYT                  ; 8-bit parameter ==> x
        CPX #$20                        ; compare input with #32 (max amount of blocks +1)
        BCS L11B5                       ; if higher then 31, branch do illegal quantity error
        LDA $A8                         ; 
        PHA                             ; save
        TXA                             ; get block number into accu
        JSR CALC_BLKADR                 ; calculate the block address and save it into $AE/$AF
        PLA
        STA $A8
        LDY #$03
-       LDA ($AE),Y
        STA DATA_START,Y
        DEY
        BPL -
        RTS
---------------------------------
chkfrom
        CMP #OWN_TK_FROM                ; check token FROM
        BEQ +
        CMP #$2C                        ; or comma
        BEQ +
        RTS
---------------------------------
; handle address set from FROM input
+       JSR CBM_CHRGET                  ; get next char
        JSR GETADDR                     ; get address, and check it for $FFF9
        STX DATA_START                  ; store as new start low byte
        STA DATA_START+1                ; store as new start high byte
        JSR CBM_CHRGOT                  ; get back last input char
        CMP #CBM_TK_TO                  ; token TO ???
        BEQ +                           ; set end address
        CMP #$2C                        ; comma?
        BEQ +                           ; set end address
        RTS
---------------------------------
; handle set end address
+       JSR CBM_CHRGET
        JSR GETADDR                     ; get address, and check it for $FFF9
        STX DATA_END                    ; store as new end address low byte
        STA DATA_END+1                  ; store as new end address high byte
        CMP DATA_START+1                ; compare with start high byte
        BEQ +                           ; equal, check low byte
        BCS ++                          ; less then, rts
        JMP illqu_error                 ; else illegal quantity error
---------------------------------
+       CPX DATA_START                  ; compare with start low byte
        BCS ++                          ; less then, rts
        JMP illqu_error                 ; else illegal quantity error
---------------------------------
++      RTS
---------------------------------
DATA_START      !word $A000
DATA_END        !word $FFF8
; ----------------------------------------------
; - $1288 HEAR ---------------------------------
; ---------------------------------------------- 
CMD_HEAR
L1288   JSR L12B0                       ; call subroutine L12B0
--      LDA $DC00                       ; read joystick port 2 data
        AND #$03                        ; separate bit 0 (up) and bit 1 (down)
        TAX
        LDA COLTABLE,X                  ; load color from table
        STA $D020                       ; store as frame color
        LDA VOLTABLE,X                  ; load volume from table
        STA $D418                       ; set volume level
delay_hear
        LDA #$00                        ; this byte will be modified during execution of the command
        CLC                             ; this code is maybe not necessary
        ADC #$00                        ; the next 'tay' should be enough, or it's a time delay?
        TAY                             ; transfere to Y
-       DEY                             ; decrement
        BPL -                           ; loop if Y is positive
        LDA $DC01                       ; check nmi?
        CMP #$FF                        ; compare the read data with $FF
        BEQ --                          ; loop if there is no change
        JMP break                       ; else jump to break
---------------------------------
L12B0   JSR CBM_CHRGOT                  ; get last last input char
        CMP #OWN_TK_SPEED               ; compare with 'Speed" token
        BNE L12C7                       ; branch to L12C7 if they are not equal
        JSR CBM_CHRGET                  ; else, get next char (speed value)
        JSR CBM_GETBYT                  ; read an 8-bit parameter into X
        STX delay_play+1                ; modify delay in play command
        STX delay_hear+1                ; modify delay in hear command
        DEX
        STX delay_rec+1                ; modify delay in rec command
L12C7   BIT L1555           ; Perform a bitwise AND with L1555
        BMI clear_sid                   ; jump to clear sid if the result is negative
        LDA $D011                       ; read screen status
        STA scn_stat                    ; save into buffer
        LDA $D020                       ; ead the current border color
        STA col_buff                    ; save into buffer
        LDA $D015                       ; read additional screen information (sprite?)
        STA sprite_flag                 ; save into buffer
        BIT status                      ; perform a bitwise AND with status-flag
        BMI clear_sid                   ; jump to clear SID if the result is negative
        LDA #$00                        ; load $00
        STA $D015                       ; switch off all sprites
        LDA #$0B                        ; load #$0b
        STA $D011                       ; switch off screen?
; $12ED clear SID registers
clear_sid
        LDA #$00                        ; Set the value to $00
        LDY #$14                        ; load Y to $14
-       STA $D400,Y                     ; store the value in $D400,y
        DEY
        BPL -                           ; loop
; set NMI vector
        LDA #<break_nmi
        STA $FFFA
        LDA #>break_nmi
        STA $FFFB
        SEI
        RTS
---------------------------------
; - $1303 break_nmi
; change 'LDA $D418' to 'JMP break' in rec and play routine
break_nmi
        SEI
        LDA #$4C                        ; jump code
        STA stp_rec
        STA stp_play
        LDA #<break                        
        STA stp_rec+1
        STA stp_play+1
        LDA #>break
        STA stp_rec+2
        STA stp_play+2

; switch on ROM
        LDA #$37
        STA $01
        STA L1555                       ; a flag
        BIT $9D                         ; check direct mode
        BPL +                           ; skip text output if not direct mode
        LDA #<stp_text
        LDY #>stp_text
        JSR CBM_STROUT                  ; print a string on the screen
        LDX $AA                         ; actual snd address low byte
        LDA $AB                         ; actual snd address high byte
        JSR printhexordec               ; output address
+       RTI
---------------------------------
; - L1336 stop text
stp_text
        !pet "stopped at ",$00
---------------------------------
; - $1342 break
break   BIT L1555
        BMI +
; restore flags and buffers
        LDA sprite_flag
        STA $D015
        LDA scn_stat
        STA $D011
        LDA col_buff
        STA $D020                       ; store as frame color
+       LDA #$37
        STA $01
        CLI
; restore command 'STA $D418' in rec and play
        LDA #$8D                        ; 'STA'
        STA stp_rec
        STA stp_play
        LDA #<$D418                     ; #$18
        STA stp_rec+1
        STA stp_play+1
        LDA #>$D418                     ; #$D4
        STA stp_rec+2
        STA stp_play+2
        RTS
; ----------------------------------------------
; - $1377 PLAY ---------------------------------
; ---------------------------------------------- 
CMD_PLAY
        LDX CBM_MEMSIZ                  ; default start low byte
        LDA CBM_MEMSIZ+1                ; default start high byte
        JSR set_def_val                 ; handle check parameter, and set start -, end address
        JSR L12B0                       ; call subroutine L12B0
x_play
        LDA DATA_START
        STA $AA                         ; actual snd address low byte
        LDA DATA_START+1
        STA $AB                         ; actual snd address high byte
        LDA DATA_END
        STA L13D0+1                     ; store in code
        LDA DATA_END+1
        STA L13D6+1
        LDY #$00
; - $1399 switch to RAM
sw_ram
        LDA #$34
        STA $01
        LDA ($AA),Y                     ; actual sound value
        STA $A6                         ; temp save
        LDA #$35
        STA $01

        LDY #$04                        ; index
--      LDA $A6                         ; get sound value
        ASL                             ;
        ADC #$00                        
        ASL
        ADC #$00
        STA $A6                         ; store as new value
        AND #$03                        ; separate bit 0 and bit 1
        TAX                             ; index
        LDA COLTABLE,X                  ; load color from table
        STA $D020                       ; store as frame color
        LDA VOLTABLE,X                  ; load volume from table
; the next values will be changed to "jmp break" if a stop is requested, and later restored back
; - $138D
stp_play
        STA $D418                       ; set volume level
delay_play
        LDX #$00                        ; this value will be changed by the speed command
-       DEX
        BPL -

        DEY
        BNE --                          ; loop

        INC $AA                         ; actual snd address low byte
        BNE +
        INC $AB                         ; actual snd address high byte
+       LDA $AA                         ; actual snd address low byte
L13D0   CMP #$00                        ; this value will be set at the beginning of the play command
                                        ; data-end address low byte
        BNE sw_ram                      ; did not reach the last address
        LDA $AB                         ; actual snd address high byte
L13D6   CMP #$00                        ; this value will be set at the beginning of the play command
                                        ; data-end address high byte
        BNE sw_ram                      ; did not reach the last address
        JMP break                       ; if it is the end, go break
; ----------------------------------------------
; - $13DD RECORD -------------------------------
; ---------------------------------------------- 
CMD_RECORD
        LDX CBM_MEMSIZ                  ; default start low byte
        LDA CBM_MEMSIZ+1                ; default start high byte
        JSR set_def_val                 ; handle check parameter, and set start -, end address
        JSR L12B0                       ; call subroutine L12B0
        LDX delay_play+1                ; read delay value
        BNE +
        JMP exit_iqerror                ; exit with illegal quantity error
---------------------------------
+       LDA DATA_START
        STA $AA                         ; actual snd address low byte
        LDA DATA_START+1
        STA $AB                         ; actual snd address high byte
        LDA DATA_END
        STA L143D+1                     ; store in code
        LDA DATA_END+1
        STA L1443+1                     ; store in code
; sound record until end address
---     LDY #$04                        ; index
--      LDA $DC00                       ; read value from joy-stick port 2
        AND #$03                        ; separate bit 0 and bit 1
        STA $A6                         ; store as snd value
        TAX                             ; index for table
        LDA COLTABLE,X                  ; load color from table
        STA $D020                       ; store as frame color
        LDA VOLTABLE,X                  ; load volume from table
; the next values will be changed to "jmp break" if a stop is requested, and later restored back
stp_rec
        STA $D418                       ; set volume level
        LDA $A8
        ASL
        ASL
        ORA $A6
        STA $A8
delay_rec
        LDX #$FF
-       DEX
        BPL -
        DEY
        BNE --                          ; loop

        LDX #$34
        STX $01
        STA ($AA),Y                      ; save as actual snd value
; switch to RAM
        LDX #$35
        STX $01
        INC $AA                         ; actual snd address low byte
        BNE +
        INC $AB                         ; actual snd address high byte
+       LDA $AA                         ; actual snd address low byte
L143D   CMP #$00                        ; this value will be set at the beginning of the record command
                                        ; data-end address low byte
        BNE ---                         ; go read next value from port
        LDA $AB                         ; actual snd address high byte
L1443   CMP #$00                        ; this value will be set at the beginning of the record command
                                        ; data-end address high byte
        BNE ---                         ; go read next value from port
        JMP break                       ; else if it is the end, go break
---------------------------------
COLTABLE        !by $0e,$06,$02,$0a
VOLTABLE        !by $07,$05,$03,$01
status          !by $00
sprite_flag     !by $00
scn_stat        !by $1b
col_buff        !by $fe
; ----------------------------------------------
; - $1456 VOLDEF -------------------------------
; ---------------------------------------------- 
; this is used to store the volume values, and also used by COLDEF
CMD_VOLDEF
        LDA #$03                        ; index
        STA $A6
-       JSR CBM_GETBYT                  ; 8-bit parameter ==> x
        TXA
        LDX $A6                         ; load index
L1460   STA VOLTABLE,X                  ; store value into table
        DEC $A6                         ; decrement index
        BMI +                           ; branch if finished
        JSR CBM_CHRGOT                  ; check last char
        BEQ +                           ; branch if there was no more input
        JSR CBM_CHKCOM                  ; check for comma at txtptr
        JMP -                           ; jmp get next
---------------------------------
+       RTS
; ----------------------------------------------
; - $1473 COLDEF -------------------------------
; ---------------------------------------------- 
; stores up to 4 screen colors
; COLDEF uses the VOLDEF routine by modifying it
CMD_COLDEF
        LDA #<COLTABLE                  ; modify
        STA L1460+1                     ; the
        LDA #>COLTABLE                  ; VOLDEF
        STA L1460+2                     ; part
        JSR CMD_VOLDEF                  ; set colors
        LDA #<VOLTABLE                  ; restore
        STA L1460+1                     ; the
        LDA #>VOLTABLE                  ; VOLDEF
        STA L1460+2                     ; part
        RTS

HEXDEC_FLAG
        !by $80
; ----------------------------------------------
; - $148C HEX ----------------------------------
; ---------------------------------------------- 
CMD_HEX
        LDA #$80
        STA HEXDEC_FLAG
        RTS
; ----------------------------------------------
; - $1492 DEZ ----------------------------------
; ---------------------------------------------- 
CMD_DEZ
        LDA #$00
        STA HEXDEC_FLAG
        RTS
; ----------------------------------------------
; - $1498 SCREEN -------------------------------
; ---------------------------------------------- 
; set the SCREEN flag - ON or OFF
; normaly during HEAR, RECORD, PLAY und EXEC the screen is switched OFF.
; with this command Speech-Basic can be used with screen switched ON
; flag could be ON or OFF or an other expression.
CMD_SCREEN
        JSR chkval
        STA status
        RTS
---------------------------------
chkval  CMP #CBM_TK_ON                  ; compare with token ON
        BNE +
        JSR CBM_CHRGET
        LDA #$80
        RTS
---------------------------------
+       CMP #OWN_TK_OFF                 ; compare with token OFF
        BNE +
        JSR CBM_CHRGET
        LDA #$00
        RTS
---------------------------------
+       JSR CBM_GETBYT                  ; 8-bit parameter ==> x
        TXA
        CMP #$00
        BNE +
        RTS
---------------------------------
+       LDA #$80
        RTS
; ----------------------------------------------
; - $14BF EXEC ---------------------------------
; ---------------------------------------------- 
; interprets the passed string as a command string
; specifying a sequence of blocks to be played.
CMD_EXEC
        JSR CBM_FRMEV                   ; evaluate expression
        JSR CBM_FRESTR                  ; evaluate string
; save actual input position
        LDA CBM_TXTPTR                  ; load low byte
        STA txtptr_buf                  ; svae
        LDA CBM_TXTPTR+1                ; load high byte
        STA txtptr_buf+1                ; save
; restore input buffer
L14CF   STX CBM_TXTPTR                  ; save low byte
        STY CBM_TXTPTR+1                ; save high byte
        JSR L12C7                       ; clear?
        LDA #$80                        ;
        STA L1555                       ;
---     JSR CBM_CHRGOT                  ; get last command value
        CMP #CHAR_COLON                        ; compare with colon
        BNE +                           ; go check exec-command char
        JSR CBM_CHRGET                  ; else get next value
        JMP ---                         ; loop
---------------------------------
+       LDY #$05                        ; index
-       CMP excmdtable,Y                ; compare with value from exec-cmd table
        BEQ +                           ; command found, get cmd address and execute
        DEY                             ; else decrement index
        BPL -
--      LDA txtptr_buf+1                ; put 2 zeros to the textptr                     
        STA CBM_TXTPTR+1
        LDA txtptr_buf
        STA CBM_TXTPTR
        LDA #$00
        STA L1555
        JMP break
---------------------------------
+       TYA
        ASL                             ; multiply with 2
        TAY                             ; address index
        LDA execaddr,Y                  ; low byte address
        STA L1516+1                     ; store
        LDA execaddr+1,Y                ; high byte address
        STA L1516+2                     ; store
        JSR CBM_CHRGET                  ; get char
L1516   JSR $FCE2                       ; jsr exec-command
        BIT L1555
        BPL --
        JMP ---
---------------------------------
; - $1521 excmdtable
excmdtable
        !by $50,$53,$57,$56,$43,$23     ; PSWVC#

execaddr
        !word exec_play                 ; exec-play
        !word exec_speed                ; exec-speed
        !word exec_pause                ; exec-pause
        !word CMD_VOLDEF                ; exec-voldef
        !word CMD_COLDEF                ; exec-coldef
        !word exec_goto                 ; exec-goto

; - $1533
txtptr_buf
        !by $00,$00

---------------------------------
; - $1535 exec-goto
exec_goto
        JSR CBM_FRMEV                   ; evaluate expression
        JSR CBM_FRESTR                  ; evaluate string
        JMP L14CF
---------------------------------
exec_play
        JSR x_blk
        JSR clear_sid
        JMP x_play
---------------------------------
; - L1547  exec-speed
exec_speed
        JSR CBM_GETBYT                  ; 8-bit parameter ==> x
        STX delay_play+1                ; modify delay in play command
        STX delay_hear+1                ; modify delay in hear command
        DEX
        STX delay_rec+1
        RTS
---------------------------------
L1555   BRK
; ----------------------------------------------
; - $1556 MON ----------------------------------
; ----------------------------------------------
CMD_MON
        LDX CBM_MEMSIZ                  ; default start low byte
        LDA CBM_MEMSIZ+1                ; default start high byte
        JSR set_def_val                 ; handle check parameter, and set start -, end address
        LDA DATA_START
        STA $AA                         ; actual snd address low byte
        LDA DATA_START+1
        STA $AB                         ; actual snd address high byte

; - $1567 mon loop
mon_loop
        LDA #$5F                        ; left arrow sign
        JSR CBM_CHROUT                  ; output to screen
; print start address
        LDX $AA                         ; actual snd address low byte
        LDA $AB                         ; actual snd address high byte
        JSR printhexordec               ; print address
; set cursor position
        LDA #$06
        JSR setcursor                   ; set position, used to print dec. value
; print colon
        LDA #CHAR_COLON                 ; load ':'
        JSR CBM_CHROUT                  ; Output
; set color
        LDA #$12                        ; 'reverse_on'
        JSR CBM_CHROUT                  ; Output

        LDA $0286                       ; org text color
        PHA                             ; save
        LDA #$08                        ; counter fo 8 bytes
        STA $A6                         ; save it
; - $158A line loop
line_loop
        SEI
; switch to RAM
        LDX #$34
        STX $01
        LDY #$00                        ; index
        LDA ($AA),Y                     ; actual snd value
; switch to ROM
        LDX #$37
        STX $01
        CLI

        JSR out_4                       ; output one byte as 4 digits with related color
        CLC
        INC $AA                         ; actual snd address low byte
        BNE +                           ; skip change high byte
        INC $AB                         ; actual snd address high byte
+       LDA $AB                         ; actual snd address high byte
        CMP DATA_END+1                  ; check high byte for data end
        BCC go_on                       ; if less, go on with output
        BEQ chk_low                     ; if equal, check low byte
; else
mon_end
        PLA                             ; get back org color
        STA $0286                       ; store as actual color
        RTS                             
---------------------------------
chk_low
        LDA $AA                         ; actual snd address low byte
        CMP DATA_END                    ; compare with data end low byte
        BNE go_on                       ; if not zero, go on with output data
        JMP mon_end                     ; else end
---------------------------------
go_on   DEC $A6                         ; decrement byte counter
        BNE line_loop                   ; branch if line is not finished
        PLA                             ; else restore color
        STA $0286
        LDA #$0D                        ; 'return'
        JSR CBM_CHROUT                  ; output
        JSR CBM_ISCNTC                  ; basic call check STP
        BEQ mon_end                     ; if stop, end
        JMP mon_loop                    ; next line
---------------------------------
; - $15CF output 4 values
; split the byte into 4 * 2 bit values, and output as digits from 0 to 4
out_4   JSR out_1
        JSR out_1
        JSR out_1
; the last jmp is not necessary
;        JMP out_1
---------------------------------
; - $15DB out_1
; get 2 bit and output as a value from 0 to 4
; on the actual screen position with the related color
out_1
; separate 2 bits
        ASL
        ADC #$00
        ASL
        ADC #$00
        PHA
        AND #$03

        TAX                             ; as index
        LDA COLTABLE,X                  ; load color from table
        STA $0286                       ; store color
        TXA                             ; get value into accu
        EOR #$03                        ; invert
        ADC #$31                        ; make digit from 4 to 1
        JSR CBM_CHROUT                  ; Output
        PLA                             ; get value back
        RTS
; ----------------------------------------------
; - $15F5 LEFTARROW ----------------------------
; this is the monitor input
; ---------------------------------------------- 
CMD_LEFTARROW
        JSR GETADDR                     ; get address, and check it for $FFF9
        STX $AA                         ; actual snd address low byte
        STA $AB                         ; actual snd address high byte
        LDA #$03                        ; load #03
        STA $A6                         ; store it as counter for 4 * 2 bit
        JSR CBM_CHRGOT                  ; get last char
        BEQ L160A                       ; branch if a colon, or nothing more
-       LDX #SYNTAX                     ; else, do syntax error
        JMP CBM_ERROR                   ; Error handling
---------------------------------
L160A   JSR CBM_CHRGET                  ; check for more input
        BEQ go_basic                    ; if nothing, do basic warm start

; handle input values
        SEC
        SBC #$31                        ; substract '1'
        BCC -                           ; error if less then '1'
        CMP #$05                        ; else compare with '5'
        BCS -                           ; error if equal or higher
        EOR #$03                        ; invert
        PHA                             ; save
        LDY $A6                         ; load counter value
        LDA mon_table,Y                 ; load corespondending value from table
        STA $AF                         ; temp storage
        PLA                             ; get back inv value
        LDY $A6                         ; load counter value
; loop
-       BEQ +                           ; branch if not count down
        ASL                             ; multyply
        ASL                             ; with 4
        DEY                             ; dec counter
        JMP -                           ; loop
---------------------------------
+       STA $AE
; switch on RAM
        SEI
        LDA #$34        
        STA $01
        LDY #$00                        ; index
        LDA ($AA),Y                     ; actual snd value
        AND $AF                         ; and bit pair
        ORA $AE                         ; ora with inserted value
        STA ($AA),Y                     ; save as new actual snd value
; switch on ROM
        LDA #$37
        STA $01
        CLI

        DEC $A6                         ; decrement counter
        BPL L160A                       ; branch if not finished

        INC $AA                         ; increment snd address low byte
        BNE +                           ; skip increment high byte if not zero 
        INC $AB                         ; increment snd address high byte
+       LDA #$03                        ; load counter
        STA $A6                         ; store
        JMP L160A                        ; do next input values
---------------------------------
go_basic
        JMP $A483                        ; do BASIC warm start
---------------------------------
mon_table
        !by $fc,$f3,$cf,$3f
---------------------------------
; Block table $165b
; the start and end addresses of the blocks are defined here
blocktabstart
        !by $00,$a0,$F8,$ff             ; block 00 cannot be defined

        !by $00,$a0,$F8,$ff             ; block 01
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff             ; block 10
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff             ; block 20
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff
        !by $00,$a0,$F8,$ff             ; block 29
        !word keytab,keynum             ; block 30
        !word blocktabstart,blocktabend ; block 31
---------------------------------
stringtable
        !pet "workblk."                 ; block text 00
; placeholder for 29 block strings
        !fill 29*8,$20

        !pet "f-tasten"                 ; block text 30
        !pet "blocktab"                 ; block text 31
blocktabend
---------------------------------
; - $17DB
exit_iqerror
        JSR break
        JMP illqu_error
end_prog


