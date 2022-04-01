#ifndef __IO__
#define __IO__
#include <pito.h>
extern volatile int utimers; // microsecond timer

struct PITOIO {
    struct PITOUART {
        unsigned char  stat; // 00
        unsigned char  fifo; // 01
        unsigned short baud; // 02/03
    } uart;
    unsigned char irq;      // 04
};

extern volatile struct PITOIO io;

extern char *board_name(int);

#define IRQ_TIMR 0x80
#define IRQ_UART 0x02

#endif