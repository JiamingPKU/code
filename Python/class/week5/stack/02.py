### 简单括号匹配
from pythonds.basic.stack import Stack


#define check function
def parChecker(symbolString):
    s = Stack()
    balanced = True
    index = 0
    while index < len(symbolString) and balanced:
        symbol = symbolString[index]
        if symbol == "(":
            s.push(symbol)
        else:
            if s.isEmpty():
                balanced=False
            else:
                s.pop()
        index += 1
    
    if s.isEmpty() and balanced:
        return True;
    else:
        return False;

# main function   
def main():
    print(parChecker("((()))"))
    print(parChecker('((())'))

# run the function
if __name__ == "__main__":
    main()
