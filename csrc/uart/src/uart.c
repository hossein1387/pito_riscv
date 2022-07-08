#include <pito.h>
#include <stdio.h>

#define N 8
extern int get_pito_hart_id();

int hart_id_cnt = 7;

void main_thread(int hart_id){
    while(hart_id_cnt!=-1){
        if (hart_id==hart_id_cnt){
            printf("Hello World from HART:%d\n", hart_id);
            hart_id_cnt = hart_id_cnt -1;
        }
    }
}

int main(){
    main_thread(get_pito_hart_id());
    return 0;
}