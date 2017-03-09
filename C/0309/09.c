#include <stdio.h>
int main(void) {
  char c1, c2;
  c1='x';
  c2='y';
  c1=c1-32;
  c2=c2-32;
  printf("%c, %c\n", c1, c2);
  return 0;
}

