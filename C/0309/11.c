#include <stdio.h>
int main(void) {
  int c;
  printf("Enter a character:");
  c=getchar();
  printf("%c--->hex%x\n", c, c);
  return 0;
}

