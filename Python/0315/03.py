
import timeit
import random

#做计时实验，验证List的按索引取值确实是O(1)


for i in range(1, 100001, 1000):
    x = list(range(i))
    t1 = timeit.Timer("k = x[random.randrange(%d)]" % i,
                     "from __main__ import x, random")
    lst_time = t1.timeit(number=1000)
    print(i,lst_time)

#做计时实验，验证Dict的get item和set item都是O(1)的
for i in range(1, 100001, 1000):
    dic = {j: None for j in range(i)}
    t2 = timeit.Timer("dic[random.randrange(%d)] = 1" % i,
                      "from __main__ import dic, random")
    getItemTime = t2.timeit(number=1000)
    t3 = timeit.Timer("k = dic[random.randrange(%d)]" % i,
                      "from __main__ import dic, random")
    setItemTime = t3.timeit(number=1000)
    print("%d,%10.5f, %10.5f" % (i, getItemTime, setItemTime))

#做计时实验，比较List和Dict的del操作符性能
print("i List Dict")
for i in range(1, 100001, 1000):
    lis = list(range(i))
    t4 = timeit.Timer("del lis[random.randrange(%d)]" % i,
                      "from __main__ import lis, random")
    delListTime = t4.timeit(number=1)

    dic = {j: None for j in range(i)}
    t5 = timeit.Timer("del dic[random.randrange(%d)] " % i,
                      "from __main__ import dic, random")
    delDictTime = t5.timeit(number=1)

    print("%d, %10.5f, %10.5f" % (i, delListTime*10000, delListTime*10000))

#给定一个随机顺序的数列表，写一个复杂度为O(nlogn)的求第k小的数的算法
def minNum(x):
    x.sort()
    return x[0]

#请改进上述的算法，使之复杂度降低为O(n)
def minNum2(x):
    k = x[0]
    for i in x:
        if k > x[i]:
            k = x[i]
    return k



