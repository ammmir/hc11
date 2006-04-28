;//.processor m68hc11
;
; File: Rts.asm
; Startup Runtime Code for project TEST, 
; cmpe121 Spring 2001, basic test code for initial board verification.
;
; This assembly code is the first to be executed following a reset or
; power-on boot. Generally, this is the place to do any reset (boot) initializations that 
; must be done during the first 64 clock cycles. 

          xdef __stext
          xref _main,  __memory

; The following lines define where code and data objects are to be located in the 
; 68HC11 memory map.  You must insure that it agrees with your hardware design.
; These "segment" or "section" boundaries are defined in the TEST.CMD file, which should
; be edited by you to make things go where they should (see discussion in this file).

	 switch .bss
__sbss:          ;label to base of bss segment (static, uninit. data)

         switch .bss
__sdata:         ;label base of data segment (init. data)

;Executable code must begin at the base of the text segment.
	 switch .text
__stext:         ;label to base of text segment (code in rom)
         clrb                   ;b=0
         ldy     #0             ;y=0
         
;setup the stack frame at the top of zpage inside the hc11
         ldx     #0ffh          ; x <- ffh
         txs                    ; sp <- x
         jmp     _main          ; execute main() in test.c
         end
