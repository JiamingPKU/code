#include <stdio.h>

int main(void){
    int x[5];
    for(int i=0;i<5;i++){
        x[i]=i+1;
        printf("%d ",x[i]);
        }
    printf("\n");
    for(int i=0;i<5;i++)
    {
        x[i]+=1;//x[i]=x[i]+1
        printf("%d ",x[i]);
    }
    printf("\n");

    for(int i=0;i<5;i++)
    {
        if(i%2==0)
            printf("%d",x[i]*100);
        else{
            x[i]=-x[i]*33;
        printf("%d",x[i]);
    }
    printf(" ");
    }
}



