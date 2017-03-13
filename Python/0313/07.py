# 输入为两行; 第一行k，是要找序列的第k小数; 第二行为序列
k = input()
s = input()

def findNum(s,k):
    k = int(k)
    s = s.split()
    for i in range(k-1):        
        s.remove(min(s))
    return min(s)

print(findNum(s,k))
