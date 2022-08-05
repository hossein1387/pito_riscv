#include <pito.h>
#include <stdio.h>

#define N 8
extern int get_pito_hart_id();
extern void wait_for_mvu_irq();
extern void enable_mvu_irq();
int hart_id_cnt=7;

static void irq_handler(void) __attribute__ ((interrupt ("machine")));

void irq_handler(){
    // First things first, disable mvu interrupt ...
    __asm__ volatile("addi t1, x0, 1 \n\t\
                      slli t1, t1, 16 \n\t\
                      csrc mip, t1");
    printf("That is interesing...\n");
    // Enable global interrupt now that we are all done
    enable_mvu_irq();
}

void main_thread(const int hart_id){
    int cnt_val = 500;
    SET_CSR(mtvec, &irq_handler);
    enable_mvu_irq();
    while(hart_id_cnt!=-1){
        if (hart_id==hart_id_cnt){
            printf("Hello World from HART:%d\n", hart_id);
            // cnt_val = cnt_val + hart_id;
            // SET_CSR(CSR_MVUCOMMAND, cnt_val);
            wait_for_mvu_irq();
            hart_id_cnt = hart_id_cnt -1;
        }
    }
}

int main(){
    main_thread(get_pito_hart_id());
    return 0;
}
