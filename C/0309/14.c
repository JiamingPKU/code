#include <stdio.h>
int fun_1(int i){
  i = 200;
}

int main(void) {
  int x;
  x = 30;
  printf("x is %d \n", x);
  fun_1(x);
  printf("x is %d", x);
}
