/**
 * memory.x
 * memory layout definition
 *
 * Author: Amir Malik <amalik@ucsc.edu>
 * Written for CMPE 121/L Spring 2006
 *
 * Based on memory.x written by Stephane Carrez (stcarrez@nerim.fr)
 * Copyright 2000, 2003 Free Software Foundation, Inc.
 */

/* Defines the memory layout for a bootstrap program.
   Pretend there is no data section.  Everything is for the text.
   The page0 overlaps the text and we have to take care of that
   in the program (this is volunteered).  */
MEMORY
{
  page0 (rwx) : ORIGIN = 0x0000, LENGTH = 0x0400
  text  (rx)  : ORIGIN = 0x8000, LENGTH = 32K
  data        : ORIGIN = 0x0800, LENGTH = 30K
  eeprom      : ORIGIN = 0xb600, LENGTH = 0
  vectors (rx): ORIGIN = 0xFFC0, LENGTH = 0x40
}

/* Setup the stack on the top of the data internal ram (not used).  */
PROVIDE (_stack = 0x7BFF);
PROVIDE (_io_ports = 0xF000);
/* PROVIDE (_io_ports = 0x1000); */
