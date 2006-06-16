/**
 * main.h
 * M68HC11 macro definitions
 *
 * Author: Amir Malik <amalik@ucsc.edu>
 * Written for CMPE 121/L Spring 2006
 */


#include <stdlib.h>

/* Part 1:  68HC11 Definitions. */

#define M6811_BAUD  0x2B  /* SCI Baud register */
#define M6811_SCCR1 0x2C  /* SCI Control register 1 */
#define M6811_SCCR2 0x2D  /* SCI Control register 2 */
#define M6811_SCSR  0x2E  /* SCI Status register */
#define M6811_SCDR  0x2F  /* SCI Data (Read => RDR, Write => TDR) */

/* Flags of the SCCR2 register.  */
#define M6811_TE    0x08  /* Transmit Enable */
#define M6811_RE    0x04  /* Receive Enable */

/* Flags of the SCSR register.  */
#define M6811_TDRE  0x80  /* Transmit Data Register Empty */
#define M6811_TC    0x60  /* Transmit Complete */
#define M6811_RDRF  0x20  /* Receive Data Register Full */

/* Flags of the BAUD register.  */
#define M6811_SCP1  0x20  /* SCI Baud rate prescaler select */
#define M6811_SCP0  0x10
#define M6811_SCR2  0x04  /* SCI Baud rate select */
#define M6811_SCR1  0x02
#define M6811_SCR0  0x01

#define M6811_BAUD_DIV_1  (0)
#define M6811_BAUD_DIV_3  (M6811_SCP0)
#define M6811_BAUD_DIV_4  (M6811_SCP1)
#define M6811_BAUD_DIV_13  (M6811_SCP1|M6811_SCP0)

#define M6811_DEF_BAUD M6811_BAUD_DIV_4 /* 1200 baud */

/* SCI */
#define SCI_RECV_BUFSIZE  128
#define SCI_SEND_BUFSIZE  128

/* Output Compare */
#define M6811_TCTL1 0x20
#define M6811_TMSK1 0x22
#define M6811_TFLG1 0x23
#define M6811_TMSK2 0x24
#define M6811_TFLG2 0x25
#define M6811_TOC5  0x1E
#define M6811_TOC5_H 0x1E
#define M6811_TOC5_L 0x1F
#define M6811_TCNT  0x0E

/* bit-masking macros */
#define SET_BIT(x, bit)       x |= (1 << bit)
#define CLEAR_BIT(x, bit)     x &= ~(1 << bit)
#define FLIP_BIT(x, bit)      x ^= (1 << bit)
#define BIT_IS_SET(x, bit)    (x & (1 << bit))
#define BIT_IS_CLEAR(x, bit)  !(x & (1 << bit))
