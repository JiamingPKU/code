#设计一个O（nlogn）的算法，找到一个序列的第四小数
s = input()


def fourthNum(s):
    #生成一个数字的列表
    s = [i for i in s.split()]
    #排序
    s.sort()
    return s[3]


print(fourthNum(s))