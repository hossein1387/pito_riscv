#include "pito_def.h"

csrr t1, mstatus
csrr t1, misa
sub  x1,x1,x1
addi x1,x1,1
ebreak

