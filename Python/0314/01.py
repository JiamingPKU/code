#做计时实验，验证List的按索引取值确实是O(1)
#做计时实验，验证Dict的get item和set item都是O(1)的
#做计时实验，比较List和Dict的del操作符性能
#给定一个随机顺序的数列表，写一个复杂度为O(nlogn)的求第k小的数的算法
#请改进上述的算法，使之复杂度降低为O(n)
import timeit
import random

# Question 1
t1 = timeit.Timer("k=x[i]", "from __main__ import x")
t2 = timeit.Timer("k=i","from __main__ import x")

for i in range(1,10000):
    k = random.randrange(%d) %i
    print("")

