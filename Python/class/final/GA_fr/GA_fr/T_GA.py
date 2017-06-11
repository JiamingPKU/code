from table import *


# read the strategy_run
f = open("run.txt", 'r')
temp = f.read().lstrip('[')
temp = temp.rstrip(']')
strategy_run = list(map(int, temp.split(',')))
f.close()
print(strategy_run)

# read the strategy_vel
f = open("vel.txt", 'r')
temp = f.read().lstrip('[')
temp = temp.rstrip(']')
strategy_vel = list(map(int, temp.split(',')))
f.close()
print(strategy_vel)

print('Already input the strategy!')


def serve(ds:dict) -> tuple:
    return BALL_POS[1], BALL_V[1]


def play(tb: TableData, ds: dict) -> RacketAction:
    ballPos = tb.ball['position'].y
    ballVel = tb.ball['velocity'].y
    index1 = ballPos // 5000  # position scope:（0，1000000）
    index2 = ballVel // (8000 / 18)  # velocity scope:（0，8000/18）

    # the gene being expressed: index1 * 5 + index2
    code = int(index1 * 5 + index2)
    return RacketAction(tb.tick, tb.ball['position'].y - tb.side['position'].y,
                        strategy_vel[code] - tb.ball['velocity'].y,
                        strategy_run[code] - tb.ball['position'].y, None, None)


def summarize(tick:int, winner:str, reason:str, west:RacketData, east:RacketData, ball:BallData, ds:dict):
    return
