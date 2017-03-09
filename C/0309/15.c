/* c6-1.c */
#include  <stdio.h>
int fac(int m)  {                 /*计算一个整数的阶乘*/
   int i, s=1;
   for(i=1; i<=m; i++)
      s*=i;
   return s;
 }
int main(void) {
  int n, k, c;
  printf("\nplease input  n, k: ");   /*输入n、k的值*/
  scanf("%d, %d", &n, &k);
  c=fac(n)/(fac(k)*fac(n-k));       /*三次调用函数fac，求n!、k!、(n-k)!*/
  printf("C(n, k)=%d\n", c);          /*输出计算结果*/
  return 0;
}
