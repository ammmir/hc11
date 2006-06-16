# Makefile for M68HC11 project
# Author: Amir Malik <amalik@ucsc.edu>
# Written for CMPE 121/L Spring 2006
# Inspired by /afs/cats.ucsc.edu/courses/cmpe012c-cb/hc11build

AS = as
ASFLAGS += --warn
LD = ld
LDFLAGS = 
OBJCOPY = objcopy
CPP = cpp
CPPFLAGS = 
CC = gcc
CFLAGS = -g -Os -mshort -Wl,-m,m68hc11elfb -I.
LINKMAP = memory.x

targets: firmware.s19

firmware.s19: boot.o main.o
	$(LD) $(LDFLAGS) -o $@ $(LINKMAP) $^
	$(OBJCOPY) --change-section-address .data=0x4000 --output-target=srec $@


%.c:
	$(CC) $(CFLAGS) $^

%.s: %.asm
	$(CPP) $(CPPFLAGS) $^ > $@

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $^

%.s19: %.o %.elf
	$(LD) $(LDFLAGS) -o $@ $(LINKMAP) $^
	$(OBJCOPY) --change-section-address .data=0x4000 --output-target=srec $@

clean:
	rm -f *.s19 *.o

.PHONY: targets
