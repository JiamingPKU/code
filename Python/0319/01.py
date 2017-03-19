import time


def fibs(num):
    result = [0, 1]
    for i in range(num - 2):
        result.append(result[-2] + result[-1])
    return result


def main():
    result = fibs(10)
    fobj = open("result.txt", "w+")
    for i, num in enumerate(result):
        print(u"the %d number is %d" % (i, num))
        fobj.write("%d" % num)
        time.sleep(1)


if __name__ == '__main__':
    main()
