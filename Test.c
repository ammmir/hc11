/*
   NAME: C-code for 121 Prototype Board Testing
   CODE: ANSI-C for 68HC11A0                                        
  TOOLS: Whitesmiths c-compiler ver 3.02                            
   FILE: test.c                                                     
 AUTHOR: S.C. Petersen            
    REV: 1.0 Fall-99/scp                                                 
         2.0 Spring-2000/scp

   This is a simple test program to be used as a first checkout of your lab prototype board.
   An infinite loop writes ascii characters from 0h to 255h out the serial
   port and to the embedded HC11 Port-D, which can be used to verify program
   execution independent of the serial port.
 */

#include "io.h"
#define TDRE    0x80             /* Transmit Ready Bit */
unsigned char x;

/* This Routine writes a single 8-bit character out the serial port.
   This is not efficient since it uses polling to 
   to check that the transmit holding register is empty before
   proceeding. 
 */
void outch(char c)
{
   while (!(SCSR & TDRE));       /*poll uart's transmit ready bit */     
   SCDR = c;                     /*we're ready, send it out       */     
}                                                                        
                                                                         
                                                                         
void main(void)                                                          
{                                                                        
   BAUD = 0x30;                  /*initialize SCI for 9600bps*/          
   SCCR2 = 0x0c;                 /*parameters for interrupt  */          
   x = 0;                                                                
                                                                         
   /* main event loop */                                                 
   for (;;) {                                                            
      ++x;                                                               
      PORTA = x;                 /*diagnostic */                         
      outch(x);                  /*write to the UART */                  
   }
}
