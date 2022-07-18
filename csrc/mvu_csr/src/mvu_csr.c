#include <pito.h>
#include <stdio.h>

#define N 8
extern int get_pito_hart_id();
extern void set_csr(int csr_addr, int csr_val);
int hart_id_cnt=0;

void main_thread(int hart_id){
    printf("Hello!! World from HART:%d\n", hart_id);
    SET_CSR(CSR_MVUCOMMAND, 0);
    while(1){};
}

int main(){
    main_thread(get_pito_hart_id());
    return 0;
}