#include <stdio.h>

int fun_1(int x){
    x = 200;
    return x;
}

int main(void){
    int x;
    x = 100;
    printf("x is %d \n",x);
    x=fun_1(x);
    printf("x is %d " ,x);
}


