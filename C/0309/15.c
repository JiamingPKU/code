/* c6-1.c */
#include  <stdio.h>
int fac(int m)  {                 /*����һ�������Ľ׳�*/
   int i, s=1;
   for(i=1; i<=m; i++)
      s*=i;
   return s;
 }
int main(void) {
  int n, k, c;
  printf("\nplease input  n, k: ");   /*����n��k��ֵ*/
  scanf("%d, %d", &n, &k);
  c=fac(n)/(fac(k)*fac(n-k));       /*���ε��ú���fac����n!��k!��(n-k)!*/
  printf("C(n, k)=%d\n", c);          /*���������*/
  return 0;
}
