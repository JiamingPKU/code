#设计一个时间复杂度为O(n)的算法，找出序列中的第4小数
s = input()

def fourthNum(x):
    #生成列表
    x = [i for i in x.split()]
    #删除第1、2、3小的数字
    for i in range(3):
        x.remove(min(x))
    #此时最小的数字就是原来第4小的
    return min(x)

print(fourthNum(s))
