#include  <stdio.h>
int main(void) {
  printf("Data type      Number of bytes\n");

  printf("char           %zu\n", sizeof(char));
  printf("short int      %zu\n", sizeof(short));
  printf("int            %zu\n", sizeof(int));
  printf("long int       %zu\n", sizeof(long));
  printf("long long int  %zu\n", sizeof(long long));

  printf("float          %zu\n", sizeof(float));
  printf("double         %zu\n", sizeof(double));
  printf("long double    %zu\n", sizeof(long double));

  printf("pointer        %zu\n", sizeof(void *));
  return 0;
}
