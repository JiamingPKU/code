from table import *
from table import Table, LogEntry, RacketData, BallData, DIM, TMAX, PL, RS
import shelve
import math
import random


# GENE definition
class Gene:
    def __init__(self, index1, index2):
        self.indexpos = index1
        self.indexvel = index2
        self.run = random.randint(0, 1000000)
        #self.vel = random.randint(-8000//18, 8000//18)-self.indexvel * 8000//18
        #self.vel = random.randint(-8000 // 18, 8000 // 18)
        up_or_down = random.random()
        if up_or_down < (self.indexpos+1)/200:  # go down
            self.vel = -1 * random.randint(5000*(self.indexpos+1)//1800, (5000*self.indexpos+2000000)//1800)
        else:  # go up
            index3 = 200-self.indexpos
            self.vel = random.randint(5000*(index3)//1800, (5000*(index3-1)+2000000)//1800)

    def mut(self):  # renew the properties
        self.run = random.randint(0, 1000000)
        #self.vel = random.randint(-8000 // 18, 8000 // 18) - self.indexvel * 8000 // 18
        #self.vel = random.randint(-8000 // 18, 8000 // 18)
        up_or_down = random.random()
        if up_or_down < (self.indexpos + 1) / 200:  # go down
            self.vel = -1 * random.randint(5000 * (self.indexpos + 1) // 1800, (5000 * self.indexpos + 2000000) // 1800)
        else:  # go up
            index3 = 200 - self.indexpos
            self.vel = random.randint(5000 * (index3) // 1800, (5000 * (index3 - 1) + 2000000) // 1800)

    def __str__(self):
        return "<%s,%s>" % (self.run, self.vel)


# GENOME generation
def GeneGenerate():
    GeneList = []
    for i in range(0, 200):
        for j in range(0, 5):
            GeneList.append(Gene(i, j))
    return GeneList


# GROUP generation
# population: you'd better choose the integer power of 2
def GroupGenerate(population):
    GroupList = []
    for i in range(0, population):
        stillalive = 1  # mark whether the individual survives in the competitions
        GroupList.append([GeneGenerate(), stillalive])
    return GroupList


##################################  modified from pingpong.py
# MODIFIED RACE
def race(west_name, west_serve, west_play, west_summarize,
         east_name, east_serve, east_play, east_summarize):
    # 生成球桌
    main_table = Table()
    main_table.players['West'].bind_play(west_name, west_serve, west_play, west_summarize)
    main_table.players['East'].bind_play(east_name, east_serve, east_play, east_summarize)

    # 发球
    main_table.serve()

    # 开始打球
    while not main_table.finished:
        # 运行一趟
        main_table.time_run()

    # only need to know who wins
    # 'West' or 'East'
    return main_table.winner


# COMPETITOR
class competitor:
    def __init__(self, n, genome):  # enter the genome of the NO.n competitor
        self.name = 'gene' + str(n)  # e.g. 'gene1'
        self.decision = genome  # the genome decide how to react to possible (pos, vel)

    def serve(self, ds: dict) -> tuple:
        return BALL_POS[1], random.randrange(500, BALL_V[1])

    def play(self, tb: TableData, ds: dict) -> RacketAction:
        ballPos = tb.ball['position'].y
        ballVel = tb.ball['velocity'].y
        index1 = ballPos // 5000  # position scope:（0，1000000）
        index2 = ballVel // (8000 / 18)  # velocity scope:（0，8000/18）

        # the gene being expressed: index1 * 5 + index2
        code = int(index1 * 5 + index2)
        return RacketAction(tb.tick, tb.ball['position'].y - tb.side['position'].y,
                            self.decision[code].vel - tb.ball['velocity'].y,
                            self.decision[code].run - tb.ball['position'].y, None, None)

    def summarize(self, tick: int, winner: str, reason: str, west: RacketData, east: RacketData, ball: BallData, ds: dict):
        return


# GENE screening
def evolution(GroupList, population):
    survival = population
    while survival > 1:

        # RECOMBINATION
        # recombination region of each gene
        start = 250
        end = 750
        for j in range(int(survival/2)):
            for k in (start, end):
                GroupList[j][0][k], GroupList[survival-1-j][0][k] = GroupList[survival-1-j][0][k], GroupList[j][0][k]

        # MUTATION
        # mutation rate
        mut_rate = 0.3  # group mutation rate
        mut_rate_gene = 0.1  # genome mutation rate
        mutationList = random.sample(range(0, survival), math.floor(survival * mut_rate))  # decide mutated individuals
        for item in mutationList:
            mutationGeneList = random.sample(range(0, 1000), int(1000 * mut_rate_gene))  # decide mutated genes
            for mutgene in mutationGeneList:
                GroupList[item][0][mutgene].mut()

        # rearrange the order
        random.shuffle(GroupList)

        ####################### hunger game!
        gametimes = 20
        for i in range(int(survival/2)):
            comp1 = competitor(i, GroupList[i][0])
            comp2 = competitor(survival-1-i, GroupList[survival-1-i][0])
            score = {str(i): 0, str(survival-1-i): 0}
            count = 0
            while count < gametimes:
                ran = random.random()  # play at west or east randomly
                if ran < 0.5:
                    winner = race(comp1.name, comp1.serve, comp1.play, comp1.summarize,
                         comp2.name, comp2.serve, comp2.play, comp2.summarize)
                    if winner == 'West':
                        score[str(i)] += 1
                    else:
                        score[str(survival-1-i)] += 1

                else:
                    winner = race(comp2.name, comp2.serve, comp2.play, comp2.summarize,
                         comp1.name, comp1.serve, comp1.play, comp1.summarize)
                    if winner == 'East':
                        score[str(i)] += 1
                    else:
                        score[str(survival-1-i)] += 1

                count += 1

            # change the state of competitors
            # lose: 0  & the genome will be removed from the group
            #  win: 1  & the genome will remain in the group
            if score[str(i)] > score[str(survival-1-i)]:
                GroupList[survival-1-i][1] = 0
            else:
                GroupList[i][1] = 0

        candidate = []
        for i in range(survival):
            if GroupList[i][1] == 1:
                candidate.append(GroupList[i])  # pick out the survivals
        GroupList = candidate  # renew the group population
        survival //= 2

    return GroupList[0][0]  # get the last survival as the optimal genome

# export the strategy into a txt
# set the population of the group
population = 1024 * 4
# evolve
GAGA = evolution((GroupGenerate(population)), population)
# combine all the genes into a list
strategy_run = []
for i in range(1000):
    strategy_run.append(GAGA[i].run)
#print(strategy_run)

f = open("run.txt", 'w')
f.write(str(strategy_run))
f.close()


strategy_vel = []
for i in range(1000):
    strategy_vel.append(GAGA[i].vel)
#print(strategy_vel)
f = open('vel.txt', 'w')
f.write(str(strategy_vel))
f.close()





