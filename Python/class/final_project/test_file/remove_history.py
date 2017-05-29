# -*- coding: utf-8 -*-
# @Author: Ren Qingjie
# @Date:   2017-05-26 16:50:50
# @Last Modified by:   Ren Qingjie
# @Last Modified time: 2017-05-27 02:00:41

import os


# 定义垃圾列表，可以自己修改
rubbishList = ["bak", "dat", "dir"]
# 定义路径,可以自定义。注意不同系统的斜线方向不同
# path = "F:\\大三下学习\\1_数据结构与算法\\final\\pingpong\\."
path = "F:\\git\\Python\\class\\final_project\\test_file\\."


# 依据文件名结尾判断是否属于腊鸡
def isRubbish(filename):
    return (filename[-3:] in rubbishList) or (filename[-2:] in rubbishList)


rubbish = [r for r in os.listdir(path) if os.path.isfile(r) and isRubbish(r)]
for r in rubbish:
    os.remove(r)
    print("%s has been Deleted" % (r))
