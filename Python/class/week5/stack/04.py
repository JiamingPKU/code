from pythonds.basic.stack import Stack

def divideBy2(decNumber):
    remstack= Stack()

    while decNumber >0:
        rem = decNumber % 2
        remstack.push(rem)
        decNumber = decNumber//2

    binString = ""
    while not remstack.isEmpty():
        binString = binString + str(remstack.pop())
    
    return binString

def main():
    print(divideBy2(42))

if __name__ == "__main__":
    main()