#!/usr/bin/python
from table import *
from neuralnetwork import NeuralGenerate, response


epsilon = 10
neuralnum = 64

# read the groupweight
f = open("weight1.txt", 'r')
temp = f.read().lstrip('[')
temp = temp.rstrip(']')
group_weight = list(map(float, temp.split(',')))
f.close()

# generate the strategy named 'GroupList'
strategy = NeuralGenerate()
for i in range(neuralnum):
    strategy[i].inpos = group_weight.pop(0)
    strategy[i].invel = group_weight.pop(0)
    strategy[i].inlife = group_weight.pop(0)
    strategy[i].outpos = group_weight.pop(0)
    strategy[i].outvel = group_weight.pop(0)
    strategy[i].inoppos = group_weight.pop(0)

print('Already input the strategy!')


def serve(ds:dict) -> tuple:
    return BALL_POS[1], BALL_V[1]


def play(tb: TableData, ds: dict) -> RacketAction:
    ballPos = tb.ball['position'].y
    ballVel = tb.ball['velocity'].y
    currentLife = tb.side['life']
    opponentPos = tb.op_side['position'].y
    pos = ballPos / 1000000
    vel = ballVel / (30000 / 18)
    life = currentLife / 100000
    oppos = opponentPos / 1000000

    reactpos = list()
    reactvel = list()
    for i in range(len(strategy)):
        strategy[i].inSignal(pos, vel, life, oppos)
        strategy[i].resSignal(epsilon)
        reactpos.append(strategy[i].outSignal()[0])
        reactvel.append(strategy[i].outSignal()[1])
    posfinal = response(sum(reactpos), epsilon)
    velfinal = response(sum(reactvel), epsilon)

    # divide = random.random()
    # if divide < (ballPos / 1000000):
    #     decision_vel = (-1) * ((ballPos // 1800 + 1) + int((2000000 / 1800) * velfinal))
    # else:
    #     decision_vel = ((1000000 - ballPos) // 1800 + 1) + int((2000000 / 1800) * velfinal)
    if velfinal <= 0.5:
        decision_vel = (-2000000 - ballPos) // 1800 + 1 + int((2000000 / 1800) * velfinal * 2)
    else:
        decision_vel = (1000000 - ballPos) // 1800 + 1 + int((2000000 / 1800) * (velfinal - 0.5) * 2)

    decision_pos = int(posfinal * 1000000)
    return RacketAction(tb.tick, tb.ball['position'].y - tb.side['position'].y,
                        decision_vel - tb.ball['velocity'].y,
                        decision_pos - tb.ball['position'].y, None, None)


def summarize(tick:int, winner:str, reason:str, west:RacketData, east:RacketData, ball:BallData, ds:dict):
    return
