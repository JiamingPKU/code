from pythonds.basic.queue import Queue

import random


# def Printer
class Printer:
    def __init__(self, ppm):
        self.pagerate=ppm
        self.currentTask=None
        self.timeRemaining = 0

    def tick(self):
        if self.currentTask != None:
            self.timeRemaining = self.timeRemaining-1
            if self.timeRemaining <= 0:
                self.currentTask = None
        
    def busy(self):
        if self.currentTask != None:
            return True
        else:
            return False
    


    def startNext(self, newtask):
        self.currentTask = newtask
        self.timeRemaining = newtask.getPages()*60/self.pagerate
    
# def task 
    class Task:
        def __init__(self, time):
            self.timestamp = time
            self.pages=random.randrange(1,21)

        def getStamp(self):
            return self.timestamp
        
        def getPages(self):
            return self.pages
        
        def waitTime(self, currenttime):
            return currenttime - self.timestamp


# simulation
