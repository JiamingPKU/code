#做计时实验，验证List的按索引取值确实是O(1)
import timeit
import random

for i in range(1, 100001, 1000):
    x = list(range(i))
    t = timeit.Timer("k = x[random.randrange(%d)]" % i,
                     "from __main__ import x, random")
    lst_time = t.timeit(number=1000)
    print(i,lst_time)
