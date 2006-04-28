/* 
    FILE: IVECTORS.C
 PURPOSE: interrupt vector table for 68HC11 Project
    CODE: Cosmic C v4.1m 
  AUTHOR: S.C. Petersen
 HISTORY: //Spring-01: created from Cosmic's original template.
*/

#include <stdlib.h>
extern void _stext();   // startup routine defined in rts.asm

// This vector table contains ordinal 16-bit pointers to ISR's, and is located
// at the top of addressable memory in ROM beginning at FFD6h.

void (* const _vectab[])() = {
   NULL,                // SCI            
   NULL,                // SPI             
   NULL,                // Pulse acc input 
   NULL,                // Pulse acc overf 
   NULL,                // Timer overf     
   NULL,                // Output compare 5
   NULL,                // Output compare 4
   NULL,                // Output compare 3
   NULL,                // Output compare 2
   NULL,                // Output compare 1
   NULL,                // Input capture 3 
   NULL,                // Input capture 2 
   NULL,                // Input capture 1 
   NULL,                // Real time       
   NULL,                // IRQ             
   NULL,                // XIRQ            
   NULL,                // SWI             
   NULL,                // illegal         
   NULL,                // cop fail        
   NULL,                // cop clock fail  
   _stext,		// RESET           
};

