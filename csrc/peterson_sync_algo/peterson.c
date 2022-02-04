/* 8-way mutual exclusion */
#include "pito_def.h"
#define N 8
extern int get_pito_hart_id();

volatile int level[N]={0};
volatile int last_to_enter[N]={0};

void main_thread(int hart_id){
    volatile int j, k, l, do_wait;
//     printf("Thread %d/%d beginning execution!\n", i, N);
    
    for(j=0;j<1000000;j++){
        for(l=0 ; l<N-1; l++){
            level[hart_id]         = l;
            last_to_enter[l] = hart_id;
            do{
                do_wait = last_to_enter[l] == hart_id;
                for(k=0; do_wait && k<N;k++){
                    if(k == hart_id) continue;
                    if(level[k] >= l){  
                        break;
                    }
                }
                do_wait = do_wait && k<N;
            }while(do_wait);
        }
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
        __asm__ volatile ("nop"::);
//         fprintf(stdout, "Thread %d entered critical section... \"", i);
//         fflush (stdout);
        
//         /* CRITICAL SECTION */
//         fprintf(stdout, "Thread %d iteration %d... ", i, j);
//         fflush (stdout);
        
//         /* Exit critical section */
//         fprintf(stdout, "\"  Thread %d exiting critical section.\n", i);
//         fflush (stdout);
        level[hart_id] = -1;
    }
    
    
}

int main(){
    main_thread(get_pito_hart_id());
    return 0;
}
