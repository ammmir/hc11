; boot.asm
; M68HC11 expanded-mode boot code
;
; Author: Amir Malik <amalik@ucsc.edu>
; Written for CMPE 121/L Spring 2006
; Portions of this file are based on v2_18g3.asm distributed with CE12 Microkit

#include "buildversion.s"

#ifndef VERSION
#define VERSION "1.0"
#endif

#ifndef BUILDDATE
#define BUILDDATE "unknown"
#endif

#define REGBASE     0xF000          // originally: 0x1000
//#define REGBASE     0x1000          // originally: 0x1000
#define TCNT        REGBASE+0x0E    // master Timer Counter
#define TCTL1       REGBASE+0x20    // Timer Control Register 1
#define TMSK1       REGBASE+0x22    // Timer Interrupt Mask 1 Register
#define TFLG1       REGBASE+0x23    // Timer Interrupt Flag 1 Register
#define TMSK2       REGBASE+0x24    // Timer Interrupt Mask 2 Register
#define TFLG2       REGBASE+0x25    // Timer Interrupt Flag 2 Register
#define PACTL       REGBASE+0x26    // Pulse Accumulator Control
#define BAUD        REGBASE+0x2b    // sci baud register
#define SCCR1       REGBASE+0x2c    // sci control1 register
#define SCCR2       REGBASE+0x2d    // sci control2 register
#define SCSR        REGBASE+0x2e    // sci status register
#define SCDR        REGBASE+0x2f    // sci data register
#define OPTION      REGBASE+0x39
#define CONFIG      REGBASE+0x3f    // originally: 0x103F
#define INIT        0x103D

  .sect page0
  .global _.frame
  .global _.d1
  .global _.d2
  .global _.d3
  .global _.d4
  .global _.z
  .global _.xy
  .global _.tmp
_.tmp:
  .word 0
_.z:
  .word 0
_.xy:
  .word 0
_.frame:
  .word 0
_.d1:
  .word 0
_.d2:
  .word 0
_.d3:
  .word 0
_.d4:
  .word 0

  .sect .vectors
  .global vectors
vectors:
  .word def                   ; ffc0
  .word def                   ; ffc2
  .word def                   ; ffc4
  .word def                   ; ffc6
  .word def                   ; ffc8
  .word def                   ; ffca
  .word def                   ; ffcc
  .word def                   ; ffce
  .word def                   ; ffd0
  .word def                   ; ffd2
  .word def                   ; ffd4

  ;; SCI
  .word interrupt_sci         ; ffd6

  ;; SPI
  .word def                   ; ffd8
  .word def                   ; ffda (PAII)
  .word def                   ; ffdc (PAOVI)
  .word def                   ; ffde (TOI)

  ;; Timer Output Compare
  .word interrupt_oc5         ; ffe0 (OC5)
  .word def                   ; ffe2 (OC4)
  .word def                   ; ffe4 (OC3)
  .word def                   ; ffe6 (OC2)
  .word def                   ; ffe8 (OC1)

  ;; Timer Input compare
  .word def                   ; ffea (IC3)
  .word def                   ; ffec (IC2)
  .word def                   ; ffee (IC1)

  ;; Misc
  .word def                   ; fff0 (RTII)
  .word interrupt_irq         ; fff2 (IRQ)
  .word interrupt_xirq        ; fff4 (XIRQ)
  .word def                   ; fff6 (SWI)
  .word def                   ; fff8 (ILL)
  .word def                   ; fffa (COP Failure)
  .word def                   ; fffc (COP Clock monitor)
  .word _start                ; fffe (reset)


;*******************************************************************************
; Write the NULL-terminated string whose starting address is in Y
; Clobbers: A, B, Y

.macro OUTSTRING_stackless:
_OUTSTRINGstart\@:
  ldaa    0, y                ; get character into A
  cmpa    #0x00
  beq     _OUTSTRINGdone\@    ; we're done if it's NULL

  ; output the char in A
_OUTCHARstart\@:
  ldab    SCSR                ; read SCSR
  bitb    #0x80               ; get TDRE bit
  beq     _OUTCHARstart\@     ; loop until TDRE = 1
  staa    SCDR                ; write character

  iny
  bra     _OUTSTRINGstart\@
_OUTSTRINGdone\@:
  nop                         ; kludge required for assembler
.endm


;*******************************************************************************
; Write the upper nibble of A to the serial port as a hex character
; Clobbers: A, B
.macro OUTHEX_stackless:
  ;;tba
  anda    #0xF0               ; mask low nibble
  lsra
  lsra
  lsra
  lsra
  cmpa    #0x0A               ; compare with 10 (decimal vs hex)
  blt     _OUTHEXdigit\@      ; A = [0:9]
  suba    #0x0A               ; convert A-F to 0-5
  adda    #'A'                ; add hex bias (to bump it back to A-F in ASCII)
  suba    #'0'                ; bias already added above; hack for next line.
_OUTHEXdigit\@:
  adda    #'0'                ; add ASCII bias

_OUTCHARStart\@:
  ldab    SCSR                ; read SCSR
  bitb    #0x80               ; get TDRE bit
  beq     _OUTCHARStart\@     ; loop until TDRE = 1
  staa    SCDR                ; write character
.endm



;*******************************************************************************
; HC11 boot code and other code to be run within the first 64 clock cycles
  .sect .text
  .global _start
def:                          ; default interrupt
  rti

_start:                       ; label to the base of the text segment

  ; move the 64B register block from 0x1000 to 0xF000
  ldaa    #0x0F               ; REG3 = REG2 = REG1 = REG0 = 1
  staa    INIT

  ; disable on-chip ROM & EEPROM
  ldaa    #0x0C               ; NOSEC=1, NOCOP=1, ROMON=0, EEON=0
  staa    CONFIG

  ; change prescaler to 8us resolution (must be done within 64 clock cycles)
  ldaa    #0x03               ; PR1 = PR0 = 1
  staa    TMSK2

  ; set up output capture on OC5
  ldaa    #0x00               ; we do not want output pins to be changed
  staa    TCTL1
  ldaa    #0x08               ; select OC5
  staa    TMSK1               ; mask enable

  ; set up the SCI interface
  ldaa    #0x30               ; 9600 baud
  staa    BAUD
  ldaa    #0x00
  staa    SCCR1
  ldaa    #0x0C               ; no interrupts yet
  staa    SCCR2

  ; print the boot screen
  ldy     #bootmsg0
  OUTSTRING_stackless         ; clrscr and print BIOS banner

  ; print message
  ldy     #bootmsg3
  OUTSTRING_stackless

  jmp     MemoryTest

;*******************************************************************************
; Address Line Tester (clobbers registers)
; !!! NOT USED -- DOES NOT WORK AS EXPECTED :( !!!

AddrCheck:
  clra
  clrb
  ldx     #0x0000             ; starting address in RAM
AddrCheckWrite:
  txs                         ; save X to SP
  xgdx                        ; D <--> X
  tsx                         ; restore SP to X
  stab    0, x                ; Mem(X) = A
  inx                         ; increment address
  cpx     #0x8000             ; end of RAM?
  bhi     AddrCheckRead
  bra     AddrCheckWrite 
AddrCheckRead:
  ldx     #0x0000
AddrCheckRead0:
  ldaa    0, x
  inx
  cmpa    255, x
  bne     AddrCheckBad
  cpy     #0x7EF9
  beq     AddrCheckDone
  blo     AddrCheckRead0
AddrCheckBad:
  ldy     #bootmsg4a
  OUTSTRING_stackless
  jmp     Halt                ; abort boot (may not be reliable!)
  txs
  tsy
  xgdx
  OUTHEX_stackless
  bra     AddrCheckRead0
AddrCheckDone:


;*******************************************************************************
; Memory Tester (clobbers registers)
MemoryTest:
_MemTest0:

  ; check 0000-77FF (RAM range)
  ldx     #0x0000             ; starting address

_MemoryTestGo:
  ldaa    #0xFF               ; test pattern
  staa    0, x                ; store pattern in memory
  cmpa    0, x                ; compare A and Mem(X)
  bne     _MemoryTestBad      ; verification failed!

  ldaa    #0x00               ; test pattern
  staa    0, x                ; store pattern in memory
  cmpa    0, x                ; compare A and Mem(X)
  bne     _MemoryTestBad      ; verification failed!

_MemoryTestNext:
  inx                         ; increment address
  cpx     #0x77FF             ; are we at the end?
  beq     _MemoryTestDone
  bra     _MemoryTestGo

_MemoryTestBad:
  ldy     #bootmsg4b
  OUTSTRING_stackless

  ; print out address in X
  txs                         ; save X to SP
  xgdx                        ; swap D and X
  
  ; print first nibble
  OUTHEX_stackless            ; clobber D
  xgdx                        ; restore D
  tsx                         ; restore X

  ; print second nibble
  xgdx
  lsla
  lsla
  lsla
  lsla
  OUTHEX_stackless            ; clobber D
  xgdx                        ; restore D
  tsx                         ; restore X

  ; print third nibble
  xgdx
  tba
  OUTHEX_stackless            ; clobber D
  xgdx                        ; restore D
  tsx                         ; restore X

  ; print fourth nibble
  xgdx
  tba
  lsla
  lsla
  lsla
  lsla
  OUTHEX_stackless            ; clobber D
  xgdx                        ; restore D
  tsx                         ; restore X

_MemTest6:
  bra     _MemoryTestNext     ; continue to next address

_MemoryTestDone:
  ldy     #bootmsg5
  OUTSTRING_stackless


FinalizeSCI:
  ldaa    #0xAC               ; full RX/TX interrupt-driven mode
  staa    SCCR2

  ; newline
  ldy     #bootmsg6
  OUTSTRING_stackless

  ; clean up
  clra
  clrb
  ldx     #0
  ldy     #0

  ; set up the stack
  lds     #0x7BFF             ; sp <- 8000 - 1K - 1

  ; enable interrupts
  cli

InvokeMain:
  jsr     main                ; jump to event loop in main()

  ; something is wrong
  sei
  ldy     #bootmsg9
  OUTSTRING_stackless

Halt:
  bra     Halt


bootmsg0:     .ascii  "\x1B[2J\x1B[0;0H"
bootmsg0a:    .ascii  "\x1B[?7"    ; auto-wrap
bootmsg0b:    .ascii  "\x1B[?3"    ; 80 columns wide
bootmsg0c:    .ascii  "\x1B[0;22r" ; 0-22 usable lines, 23 is clock line
bootmsg1:     .ascii  "      _\r\n     / \\\r\n    / _ \\    AmirBIOS\r\n   / ___ \\   (c) 2006            Version " VERSION "\r\n  /_/   \\_\\\r\n"
bootmsg2:     .ascii  "\r\n  BIOS Build Date " BUILDDATE "\r\n\r\n  On-chip ROM & EEPROM disabled.\r\n  SCI initialized.\r\n  Detected 30 KB RAM.\000"
bootmsg3:     .asciz  " Verifying... "
bootmsg4a:    .asciz  "\r\n    Please check address line wiring!"
bootmsg4b:    .asciz  "\r\n    Bad memory location: 0x"
bootmsg5:     .ascii  "\r\n  ...DONE!"
bootmsg6:     .asciz  "\r\n"
bootmsg9:     .asciz  "\r\nBIOS: System halted.\r\n"


#if 0
;*******************************************************************************
; Write the character in A out to the serial port
OUTCHAR:
  pshb                      ; save B
_OUTCHARStart:
  ldab    SCSR              ; read SCSR
  bitb    #0x80             ; get TDRE bit
  beq     _OUTCHARStart     ; loop until TDRE = 1
  staa    SCDR              ; write character
  pulb                      ; restore B
  rts                       ; return

;*******************************************************************************
; Write the NULL-terminated string whose address is in X to the serial port
OUTSTRING:
  psha
_OUTSTRINGStart:
  ldaa    0, x              ; get character into A
  cmpa    #0x00
  beq     _OUTSTRINGDone    ; we're done if it's NULL
  jsr     OUTCHAR           ; write the char
  inx
  bra     _OUTSTRINGStart
_OUTSTRINGDone:
  pula
  rts
#endif



#if 0
;*******************************************************************************
; Write the upper nibble of A to the serial port as a hex character
; Clobbers: A, B, Y
; Return address is stored in SP
OUTHEX_stackless:
  ;;tba
  anda    #0xF0             ; mask low nibble
  lsra
  lsra
  lsra
  lsra
  cmpa    #0x0A             ; compare with 10 (decimal vs hex)
  blt     _OUTHEXdigit      ; A = [0:9]
  suba    #0x0A             ; convert A-F to 0-5
  adda    #'A'              ; add hex bias (to bump it back to A-F in ASCII)
  suba    #'0'              ; bias already added above; hack for next line.
_OUTHEXdigit:
  adda    #'0'              ; add ASCII bias

_OUTCHARStart:
  ldab    SCSR              ; read SCSR
  bitb    #0x80             ; get TDRE bit
  beq     _OUTCHARStart     ; loop until TDRE = 1
  staa    SCDR              ; write character

  tsy
  jmp     0, y
#endif


#if 0
;*******************************************************************************
; Write lower nibble of B to the serial port as a hex character
OUTHEX:
  psha
  tba
  anda    #0x0F             ; mask low nibble
  cmpa    #0x0A             ; compare with 10 (decimal vs hex)
  blt     _OUTHEXdigit      ; A = [0:9]
  suba    #0x0A             ; convert A-F to 0-5
  adda    #'A'              ; add hex bias (to bump it back to A-F in ASCII)
  suba    #'0'              ; bias already added above; hack for next line.
_OUTHEXdigit:
  adda    #'0'              ; add ASCII bias
  jsr     OUTCHAR
  pula
  rts


;*******************************************************************************
; Write register B to the serial port as two hex characters
OUTB:
  pshb                      ; remember: OUTHEX prints lower nibble
  lsrb
  lsrb
  lsrb
  lsrb
  jsr     OUTHEX
  pulb
  jsr     OUTHEX
  rts

;*******************************************************************************
; Write register D to the serial port as four hex characters
OUTD:
  pshb
  tab
  jsr     OUTB
  pulb
  jsr     OUTB
  rts
#endif


#if 0
;*******************************************************************************
; Memory Tester (clobbers registers)
; Returns MemoryTestDone label
MemoryTest:
  ldx     #bootmsg3
  jsr     OUTSTRING

  ; check 0000-77FF (RAM range)
  ldy     #0x0000           ; starting address

_MemoryTestGo:
  ldaa    #0xFF             ; test pattern
  staa    0, y              ; store pattern in memory
  cmpa    0, y              ; compare A and Mem(X)
  bne     _MemoryTestBad    ; verification failed!

  ; same test, but now try writing zeros
  ldaa    #0x00             ; test pattern
  staa    0, y              ; store pattern in memory
  cmpa    0, y              ; compare A and Mem(X)
  bne     _MemoryTestBad    ; verification failed!

_MemoryTestNext:
  iny                       ; increment address
  cpy     #0x77FF           ; are we at the end?
  beq     _MemoryTestDone
  bra     _MemoryTestGo

_MemoryTestBad:
  ldx     #bootmsg4b
  jsr     OUTSTRING
  xgdy
  jsr     OUTD
  xgdy
  bra     _MemoryTestNext   ; continue to next address

_MemoryTestDone:
  ldx     #bootmsg5
  jsr     OUTSTRING
  jmp     MemoryTestDone
#endif

  end
