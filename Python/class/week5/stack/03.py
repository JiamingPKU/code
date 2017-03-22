### 简单括号匹配
from pythonds.basic.stack import Stack


#def match function
def matches(open, close):
    opens = "([{"
    closers = ")]}"
    return opens.index(open) == closers.index(close)


#define check function
def parChecker(symbolString):
    s = Stack()
    balanced = True
    index = 0
    while index < len(symbolString) and balanced:
        symbol = symbolString[index]
        if symbol in "([{":
            s.push(symbol)
        else:
            if s.isEmpty():
                balanced = False
            else:
                top =s.pop()
                if not matches(top, symbol):
                    balanced= False;

        index += 1

    if s.isEmpty() and balanced:
        return True
    else:
        return False


# main function   
def main():
    print(parChecker("((()))"))
    print(parChecker('((())'))
    print(parChecker("{{([][])}()}"))
    print(parChecker("[{()]"))

# run the function
if __name__ == "__main__":
    main()
