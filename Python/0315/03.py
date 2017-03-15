#做计时实验，验证List的按索引取值确实是O(1)
import timeit
import random

# for i in range(1, 100001, 1000):
#     x = list(range(i))
#     t1 = timeit.Timer("k = x[random.randrange(%d)]" % i,
#                      "from __main__ import x, random")
#     lst_time = t1.timeit(number=1000)
#     print(i,lst_time)

#做计时实验，验证Dict的get item和set item都是O(1)的
# for i in range(1, 100001, 1000):
#     dic = {j: None for j in range(i)}
#     t2 = timeit.Timer("dic[random.randrange(%d)] = 1" % i,
#                       "from __main__ import dic, random")
#     getItemTime = t2.timeit(number=1000)
#     t3 = timeit.Timer("k = dic[random.randrange(%d)]" % i,
#                       "from __main__ import dic, random")
#     setItemTime = t3.timeit(number=1000)
#     print("%d,%10.5f, %10.5f" % (i, getItemTime, setItemTime))

#做计时实验，比较List和Dict的del操作符性能
