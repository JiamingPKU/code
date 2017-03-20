class(Queue):
    def __init__(self):
        self.items=[]
    
    def isEmpty(self):
        return self.items==[]

    #这里右边/list的末端作为队尾,入队O(n),出队O(1)
    def enqueue(self, item):
        self.item.insert(0,item)

    def dequeue(self):
        return self.items.pop()
    
    def size(self):
        return len(self.items)
