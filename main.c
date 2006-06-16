/**
 * main.c
 * M68HC11 kernel
 *
 * Author: Amir Malik <amalik@ucsc.edu>
 * Written for CMPE 121/L Spring 2006
 */


#include "main.h"

/* reference to _start in boot.asm */
extern void _start();

/* interrupt definitions for boot.asm */
extern void interrupt_sci(void) __attribute__((interrupt));
extern void interrupt_rti(void) __attribute__((interrupt));
extern void interrupt_oc5(void) __attribute__((interrupt));
extern void interrupt_irq(void) __attribute__((interrupt));
extern void interrupt_xirq(void) __attribute__((interrupt));

/* 64 byte I/O register block. Address defined in memory.x */
extern volatile unsigned char _io_ports[];

/** SCI buffers
 * For RX and TX, we have FIFO queues to manage data buffering.
 * Each queue has a head and a tail pointer, both initialized to zero.
 * When writing to a buffer, putc() pushes data to the tail.
 * When reading from a buffer, getc() pulls data from the head.
 *
 * The following TX example assumes "Hello, " has been sent.
 *
 *                            tail
 *                             |
 * ,-----------------------------,
 * | H e l l o ,   w o r l d ! . |
 * `-----------------------------'
 *                 |
 *                head
 *
 * To write a character:
 *   if send buffer is empty
 *     write directly to serial port
 *   else
 *     write char to buffer[tail]
 *     tail++
 *     if tail >= BufferSize    ; all pending data has been sent
 *       tail = 0
 *
 * To read a character:
 *   if receive buffer is empty
 *     return NULL
 *   else
 *     c = buffer[head]
 *     head++
 *     if head >= BufferSize    ; xxx
 *       head = 0
 *     return c
 *
 * In the interrupt handler routine, we must manage the buffers as data is
 * sent/received:
 *   if transmitterIsFree
 *     if head != tail
 *       transmit buffer[head]
 *       head++
 *       if head >= BufferSize
 *         head = 0
 *     if head == tail
 *       head = 0
 *       tail = 0
 *       disableTransmitInterrupt
 *   else if dataReceived
 *     if tail != head - 1
 *       receive into buffer[head]
 *       head++
 *       if tail >= BufferSize
 *         tail = 0
 *
 * What about blocking if tail >= BufferSize and the transmitter
 * hasn't caught up with the data rate?
 */
char SCI_RECV_BUFFER[SCI_RECV_BUFSIZE];
char SCI_SEND_BUFFER[SCI_SEND_BUFSIZE];
unsigned char sciRecvHead;
unsigned char sciRecvTail;
unsigned char sciSendHead;
unsigned char sciSendTail;

/* Timer */
unsigned char curtime;
unsigned char time[5]; /* h, m, s, ds, div */


/*******************************************************************************
 ******************************* INTERRUPTS ************************************
 ******************************************************************************/

/* IRQ interrupt (2nd pushbutton on board */
void __attribute__((interrupt)) interrupt_irq (void) {
  puts("INIT: IRQ asserted!");
}

/* XIRQ interrupt (not connected) */
void __attribute__((interrupt)) interrupt_xirq (void) {
  puts("INIT: XIRQ asserted!");
}

/* output-compare interrupt for TOC5 */
void __attribute__((interrupt)) interrupt_oc5 (void) {
  _io_ports[M6811_TOC5] = _io_ports[M6811_TCNT] - 0x1;
  _io_ports[M6811_TFLG1] &= 0x08;

    time[4] = 0;

    if(time[3]++ == 1) {
      time[3] = 0;

      time[2]++;
  
      if(time[2] > 59) {                        /* next minute? */
        time[2] = 0;                            /* zero seconds */
        time[1]++;                              /* increment minute */
    
        if(time[1] > 59) {                      /* next hour? */
          time[1] = 0;                          /* zero minute */
          time[0]++;
    
          if(time[0] > 23) {                    /* next day? */
            time[0] = 0;                        /* zero hour */
          }
        }
      }
    }
}

/* real-time interrupt (not currently used) */
void __attribute__((interrupt)) interrupt_rti (void) {
  /* we'll be called E/2^13 times per second, ie. every 4.096 ms */
  _io_ports[M6811_TFLG2] &= 0x7F;

  if(time[3] > 244) {
    time[3] = 0;
    time[2]++;

    if(time[2] > 59) {                        /* next minute? */
      time[2] = 0;                            /* zero seconds */
      time[1]++;                              /* increment minute */
  
      if(time[1] > 59) {                      /* next hour? */
        time[1] = 0;                          /* zero minute */
        time[0]++;
  
        if(time[0] > 23) {                    /* next day? */
          time[0] = 0;                        /* zero hour */
        }
      }
    }
  } else {
    time[3]++;
  }
}

/* SCI interrupt */
void __attribute__((interrupt)) interrupt_sci (void) {
  if(_io_ports[M6811_SCSR] & M6811_RDRF) { /* ready to receive */
    if(sciRecvTail != sciRecvHead - 1) {
      SCI_RECV_BUFFER[sciRecvTail++] = _io_ports[M6811_SCDR];

      if(sciRecvTail >= SCI_RECV_BUFSIZE) {
        sciRecvTail = 0;
      }
    }

  } else if(_io_ports[M6811_SCSR] & M6811_TDRE) {  /* ready to send next byte */
    if(sciSendHead != sciSendTail) {               /* there is stuff to send */
      _io_ports[M6811_SCDR] = SCI_SEND_BUFFER[sciSendHead++];

      if(sciSendHead >= SCI_SEND_BUFSIZE) {   /* everything has been sent */
        sciSendHead = 0;
      }
    }

    if(sciSendHead == sciSendTail) {
      sciSendHead = sciSendTail = 0;
      _io_ports[M6811_SCCR2] &= 0x7F;       /* TIE = 0 */
    }
  }
}


/*******************************************************************************
 ******************************* KERNEL CODE ***********************************
 ******************************************************************************/

/* read one byte from the SCI receive buffer */
char getc(void) {
  char c;

  if(sciRecvHead != sciRecvTail) {          /* receive buffer not empty */
    asm volatile("sei");                    /* mask interrupts */

    c = SCI_RECV_BUFFER[sciRecvHead++];     /* get char from buffer */

    if(sciRecvHead >= SCI_RECV_BUFSIZE) {   /* reached end of buffer? */
      sciRecvHead = 0;
    }

    asm volatile("cli");                    /* unmask interrupts */
  } else {                                  /* receive buffer empty */
    c = sciRecvHead = sciRecvTail = 0;
  }

  return c;
}


/* write one byte to the SCI send buffer */
void putc(char c) {
  asm volatile("sei");                          /* mask interrupts */

  if(sciSendHead == sciSendTail &&
     _io_ports[M6811_SCSR] & M6811_TDRE) {      /* have something to send */
    _io_ports[M6811_SCDR] = c;
  } else if(sciSendTail != sciSendHead - 1) {   /* send buffer not empty */
    SCI_SEND_BUFFER[sciSendTail++] = c;         /* append to buffer */

    if(sciSendTail >= SCI_SEND_BUFSIZE) {
      sciSendTail = 0;
    }
  }

  asm volatile("cli");                          /* unmask interrupts */

  _io_ports[M6811_SCCR2] |= 0x80;               /* TIE = 1 */
}


int strlen(const char *string) {
  int i;

  for(i = 0; ; i++)
    if(string[i] == '\0')
      break;

  return i;
}


void write(const char *msg) {
  while(*msg != 0)
    putc(*msg++);
}

void shell_prompt(void) {
  write("# ");
}

/* write a \r\n-terminated string to the serial port */
void puts(const char *string) {
  int i;

  for(i = 0; ; i++) {
    if(string[i] == '\0') {
      putc('\r');
      putc('\n');
      break;
    }

    putc(string[i]);
  }
}

/* based on strcmp from GEL (http://gel.sourceforge.net/) */
int strcmp(const char *s1, const char *s2) {
  /* WARNING: this is unsafe! should really implement strncmp! */
  while (*s1 && (*s1 == *s2))
    s1++, s2++;

  return *s1 - *s2;
}


/* The following function is taken from FreeBSD source code:
 * $FreeBSD: src/sys/libkern/strncmp.c,v 1.11 2005/01/07 00:24:32 imp Exp $
 * Copyright (c) 1989, 1993 The Regents of the University of California */
int
strncmp(s1, s2, n)
        register const char *s1, *s2;
        register size_t n;
{

        if (n == 0)
                return (0);
        do {
                if (*s1 != *s2++)
                        return (*(const unsigned char *)s1 -
                                *(const unsigned char *)(s2 - 1));
                if (*s1++ == 0)
                        break;
        } while (--n != 0);
        return (0);
}


/* check if the given char is a delimiting character */
char isspace(char c) {
  if(c == ' ' || c == '\t') {
    return 1;
  } else {
    return 0;
  }
}

/* check if the given char is a decimal digit */
char isdigit(char c) {
  if(c >= '0' && c <= '9') {
    return 1;
  } else {
    return 0;
  }
}

/* check if the given char is a hexadecimal digit */
char ishexdigit(char c) {
  if((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F')) {
    return 1;
  } else {
    return 0;
  }
}

/* adapted from http://c-faq.com/~scs/cclass/asgn.beg/PS4a.html */
int atoi(const char *string) {
  int number, i, neg;

  number = i = neg = 0;

  while(isspace(string[i]))
    i++;

  if(string[i++] == '-')
    neg = 1;

  while(string[i] != '\0' && isdigit(string[i])) {
    number = 10*number + (string[i++] - '0');
  }

  if(neg)
    number *= -1;

  return number;
}

int htoi(const char *string) {
  int number, i, neg;

  number = i = neg = 0;

  while(isspace(string[i]))
    i++;

  if(string[i++] == '-')
    neg = 1;

  while(string[i] != '\0' && ishexdigit(string[i])) {
    number = 16*number + (string[i++] - '0');
  }

  if(neg)
    number *= -1;

  return number;
}


/* derived from itoa() by DJ Delorie */
void itoa(int value, char *string) {
  char i, j, v, r;
  char c;

  i = 0;

  if(value < 0) {
    string[i++] = '-';
    value = -value;
  } else if(value == 0) {
    string[0] = '0';
    string[1] = '\0';
    return;
  }

  v = value;

  while(v != 0) {
    r = v % 10;
    v = v / 10;

    string[i++] = '0' + r;
  }

  string[i--] = '\0';

  for(j = 0; j <= i/2; j++) {
    c = string[j];
    string[j] = string[i-j];
    string[i-j] = c;
  }
}


inline void vt100_send(const char *string) {
  putc('\x1B');
  write(string);
}


int shell_exec(const char *cmd) {
  int retval;
  unsigned int i;

  retval = 0;

  if(!strcmp(cmd, "help") || !strcmp(cmd, "?")) {
    puts("Cruz/OS Help\r\n"
         "------------\r\n"
         "help              this message\r\n"
         "baud 1200         set baud rate to 1200\r\n"
         "baud 9600         set baud rate to 9600"
        );
    for(i = 0; i < 65535; i++) {}
    puts("clear             clear the screen\r\n"
         "uptime            print the uptime of the system"
        );
    for(i = 0; i < 65535; i++) {}
    puts("reboot            reboot the system\r\n"
         "halt              halt the system\r\n"
        );
    retval = 0;

  } else if(!strcmp(cmd, "reboot")) {
    puts("INIT: Please standby as the system reboots...");
    for(i = 0; i < 65535; i++) {}
    asm volatile("sei");
    asm volatile("jmp _start");

  } else if(!strcmp(cmd, "halt")) {
    asm volatile("sei");
    puts("INIT: System halted.");
    while(1);

  } else if(!strcmp(cmd, "cls") || !strcmp(cmd, "clear")) {
    vt100_send("[2J");
    vt100_send("[0;0H");

  } else if(!strcmp(cmd, "baud 9600")) {
    asm volatile("sei");
    _io_ports[M6811_BAUD] = 0x30;
    asm volatile("cli");

  } else if(!strcmp(cmd, "baud 1200")) {
    asm volatile("sei");
    _io_ports[M6811_BAUD] = 0x33;
    asm volatile("cli");

  } else if(!strcmp(cmd, "uptime")) {
    char t[3];
    int h, m, s;

    h = time[0];
    m = time[1];
    s = time[2];

    write("System uptime is ");

    if(h > 0) {
      itoa(h, &t[0]);
      write(&t[0]);
      write(" hours, ");
    }

    if(m > 0) {
      itoa(m, &t[0]);
      write(&t[0]);
      write(" minutes, ");
    }

    itoa(s, &t[0]);
    write(&t[0]);
    write(" seconds\r\n");

  } else {
    retval = -1;
  }

  return retval;
}

void readline(char *string) {
  int i;
  char c;
  short tabs;

  tabs = 0;

  for(i = 0; ; ) {
    if((c = getc()) > 0) {
      if(c == '\r' || c == '\n') {              /* newline */
        putc('\r');
        putc('\n');
        string[i] = '\0';
        break;
      } else if(c == '\003') {                  /* Control-C */
        string[0] = '\0';
        write("\r\n");
        break;
      } else if(c == '\004') {                  /* Control-D */
        string[i] = '\0';
        write("\r\n");
        break;
      } else if(c == '\t') {                    /* tab completion */
        if(++tabs > 1) {
          puts("\r\nsh: tab completion is not available in this version");
          string[0] = '\0';
          break;
        }
      } else if(c == '\010') {                  /* backspace */
        /* get column #, so we can track excess backspaces */
        putc('\x7F');
        vt100_send("[1D");
        if(i > 0)
          i--;
      } else {                                  /* remote echo */
        putc(c);
        string[i++] = c;
      }
    }

    /* update terminal with the time every second */
    if(time[2] != curtime) {
      curtime = time[2];
      print_time(time[0], time[1], curtime);
    }
  }
}

void print_time(char h, char m, char s) {
  char t[3];

  vt100_send("7");                              /* save cursor position */
  vt100_send("[24;1H");                         /* move it down */

  if(h < 10)
    putc('0');
  itoa(h, &t[0]);
  write(&t[0]);
  write(":");

  if(m < 10)
    putc('0');
  itoa(m, &t[0]);
  write(&t[0]);
  write(":");

  if(s < 10)
    putc('0');
  itoa(s, &t[0]);
  write(&t[0]);

  vt100_send("8");                              /* restore cursor position */
}


int main() {
  unsigned int i;
  unsigned int j;
  char c;
  char line[256];
  int retval;
  sciRecvHead = sciRecvTail = 0;
  sciSendHead = sciSendTail = 0;

  char x[12];

  /* set time */
  time[0] = 0;
  time[1] = 0;
  time[2] = 0;
  time[3] = 0;
  time[4] = 0;
  curtime = 0;
  _io_ports[M6811_TOC5_H] = _io_ports[M6811_TCNT] + 8000;
  _io_ports[M6811_TFLG1] = 0x08;

  puts("INIT: Booting Cruz/OS");
  puts("Cruz/OS 0.1-CURRENT \"Red Dwarf\"");
  for(i = 0; i < 65535; i++) {}
  puts("(c) 2006 Amir Malik, Regents of the University of California");
  puts("Portions (c) 2000, 2003 Free Software Foundation, Inc.");
  for(i = 0; i < 65535; i++) {}
  write("\r\n");

  while(1) {
    /* shell prompt */
    shell_prompt();

    /* read user command */
    readline(&line[0]);

    /* execute and check return code */
    if(line[0] != '\0') {
      retval = shell_exec(&line[0]);

      switch(retval) {
        case 0:
          break;
        case -1:
          puts("sh: unknown command");
          break;
      }
    }
  }
}
