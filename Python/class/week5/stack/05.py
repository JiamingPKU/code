from pythonds.basic.stack import Stack

def baseConvert(decNumber, base):
    digits="0123456789abcdef"

    remstack=Stack()

    while decNumber > 0:
        rem = decNumber%base
        remstack.push(rem)
        decNumber = decNumber//base

    newString = ""
    while not remstack.isEmpty():
        newString = newString +digits[remstack.pop()]
    
    return newString

def main():
    print(baseConvert(25,2))
    print(baseConvert(25,16))

if __name__ == "__main__":
    main()