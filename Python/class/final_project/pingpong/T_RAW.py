from table import *
import sys
import random


def serve(ds):
    return BALL_POS[1], random.randrange(500, BALL_V[1])

def summarize(tick:int, winner:str, reason:str, west:RacketData, east:RacketData, ball:BallData, ds:dict):
    return

def play(tb, ds):
    T0 = (DIM[1] - DIM[0]) / BALL_V[0]

    def North_Range(y):
        Vmin = int((DIM[3] - y) / T0) + 1
        Vmax = int((3 * DIM[3] - y) / T0) - 1
        Vcrit = int((2 * DIM[3] - y) / T0)
        return [Vmin, Vcrit, Vmax]

    def South_Range(y):
        Vmin = int(y / T0) + 1
        Vmax = int((2 * DIM[3] + y) / T0) - 1
        Vcrit = int((DIM[3] + y) / T0)
        return [-Vmax, -Vcrit, -Vmin]

    def North_Aim(y, Vy):
        return abs(Vy * T0 - (DIM[3] - y) - DIM[3])

    def South_Aim(y, Vy):
        return DIM[3] - abs(-Vy * T0 - y - DIM[3])

    def Op_minCost_Move(start, end):
        return (abs(start - end) ** 2 / 2) // FACTOR_DISTANCE ** 2

    def maxCost_Move(y):
        return max(y, DIM[3] - y) ** 2 // FACTOR_DISTANCE ** 2

    def getVy():
        ballPos = tb.ball['position'].y
        NR = North_Range(ballPos)
        SR = South_Range(ballPos)
        EFFECT = -sys.maxsize
        Vy = None

        for v in range(NR[0], NR[1]):
            aim = North_Aim(ballPos, v)
            Cost_Acc = abs(tb.ball['velocity'].y - v) ** 2 // FACTOR_SPEED ** 2
            Op_SR = South_Range(aim)
            if Op_SR[0] <= (-v) <= Op_SR[2]:
                Op_minCost_Acc = 0
            else:
                Op_minCost_Acc = min(abs(Op_SR[0] + v), abs(Op_SR[2] + v)) ** 2 // FACTOR_SPEED ** 2
            DELTA = Op_minCost_Move(tb.op_side['position'].y, aim) + Op_minCost_Acc - maxCost_Move(ballPos) - Cost_Acc
            if DELTA > EFFECT:
                EFFECT = DELTA
                Vy = v

        for v in range(NR[1]+1, NR[2]+1):
            aim = North_Aim(ballPos, v)
            Cost_Acc = abs(tb.ball['velocity'].y - v) ** 2 // FACTOR_SPEED ** 2
            Op_NR = North_Range(aim)
            if Op_NR[0] <= v <= Op_NR[2]:
                Op_minCost_Acc = 0
            else:
                Op_minCost_Acc = min(abs(Op_NR[0] - v), abs(Op_NR[2] - v)) ** 2 // FACTOR_SPEED ** 2
            DELTA = Op_minCost_Move(tb.op_side['position'].y, aim) + Op_minCost_Acc - maxCost_Move(ballPos) - Cost_Acc
            if DELTA > EFFECT:
                EFFECT = DELTA
                Vy = v

        for v in range(SR[0], SR[1]):
            aim = South_Aim(ballPos, v)
            Cost_Acc = abs(tb.ball['velocity'].y - v) ** 2 // FACTOR_SPEED ** 2
            Op_SR = South_Range(aim)
            if Op_SR[0] <= v <= Op_SR[2]:
                Op_minCost_Acc = 0
            else:
                Op_minCost_Acc = min(abs(Op_SR[0] - v), abs(Op_SR[2] - v)) ** 2 // FACTOR_SPEED ** 2
            DELTA = Op_minCost_Move(tb.op_side['position'].y, aim) + Op_minCost_Acc - maxCost_Move(ballPos) - Cost_Acc
            if DELTA > EFFECT:
                EFFECT = DELTA
                Vy = v

        for v in range(SR[1]+1, SR[2]+1):
            aim = South_Aim(ballPos, v)
            Cost_Acc = abs(tb.ball['velocity'].y - v) ** 2 // FACTOR_SPEED ** 2
            Op_NR = North_Range(aim)
            if Op_NR[0] <= (-v) <= Op_NR[2]:
                Op_minCost_Acc = 0
            else:
                Op_minCost_Acc = min(abs(Op_NR[0] + v), abs(Op_NR[2] + v)) ** 2 // FACTOR_SPEED ** 2
            DELTA = Op_minCost_Move(tb.op_side['position'].y, aim) + Op_minCost_Acc - maxCost_Move(ballPos) - Cost_Acc
            if DELTA > EFFECT:
                EFFECT = DELTA
                Vy = v

        return Vy

    return RacketAction(tb.tick, tb.ball['position'].y - tb.side['position'].y,
                        getVy() - tb.ball['velocity'].y,
                        abs((DIM[3] - DIM[2]) // 2 - tb.ball['position'].y), None, None)
