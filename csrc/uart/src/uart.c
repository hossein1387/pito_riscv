#include <pito.h>
#include <stdio.h>

#define N 8
extern int get_pito_hart_id();

void main_thread(int hart_id){
    while(1){
        if (hart_id==0){
            printf("Hello Wolrd!\n");
        }
    }
}

int main(){
    main_thread(get_pito_hart_id());
    return 0;
}
