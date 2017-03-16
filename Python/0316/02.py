# 给定由大写，小写字母和空格组成的字符串，返回 最后 一个单词的长度。
# 如果输入中不存在单词，返回 000。
s = input()


def lastWord(s):
    s = s.split()
    if s == []:
        return "0"
    else:
        return len(s[-1])


print(lastWord(s))