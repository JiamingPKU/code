# -*- coding: utf-8 -*-
# @Author: Ren Qingjie
# @Date:   2017-06-07 18:56:19
# @Last Modified by:   Ren Qingjie
# @Last Modified time: 2017-06-08 02:19:26


from table import *
# import sys
# import copy
# import shelve


# 参数
LIFE_LIMIT = 41667         # 1/4 跑位模式下的临界生命值
LIFE_LIMIT2 = 27778
OP_LIFE_LIMIT = 30000         # 用于动态调整道具的应用价值


# 计算跑位距离
def count_run(pos, life):
    if life > LIFE_LIMIT:
        run = (DIM[3] - DIM[2]) - pos
    elif (life < LIFE_LIMIT) and (life > LIFE_LIMIT2):
        run = (DIM[3] - DIM[2]) - pos
    else:
        run = 0
        return run


# 打角速度计算
def count_acc(pos):
    up_ub = int((DIM[3] * 3 - pos) / tick_step) - 1  # bounces = 2
    up_mid = int((DIM[3] * 2 - pos) / tick_step) + 1  # bounces = 2
    up_lb = int((DIM[3] - pos) / tick_step) + 1  # bounces = 1
    down_lb = -int((DIM[3] * 2 + pos) / tick_step) + 1  # bounces = 2
    down_mid = -int((DIM[3] + pos) / tick_step) - 1  # bounces = 1
    down_ub = -int(pos / tick_step) - 1  # bounces = 1
    return [[up_lb, up_mid, up_ub], [down_lb, down_mid, down_ub]]


# 发球。模式：向上，速度最大
def serve(op_side: str, ds: dict) -> tuple:
    initialize_memory(memory)
    return 0, vel_critical(0)[0][0]


# 球到达对方的落点
def get_op_pos(pos, vel):
    if not isLegal(pos, vel):
        return
    elif vel > 0:
        return abs(vel * tick_step - (DIM[3] - pos) - DIM[3])
    else:
        return DIM[3] - abs(vel * tick_step + pos + DIM[3])


# 球到达对方的速度
def get_op_vel(pos, vel):
    op_vel = -vel
    if vel >= (DIM[3] * 2 - pos) / tick_step or vel <= -(DIM[3] + pos) / tick_step:
        op_vel = -op_vel
    return op_vel


# 打球
def play(tb: TableData, ds: dict) -> RacketAction:

    # 参数
    # vbond = secureVelocity(tb.ball['position'].y)
    # ball_pos = (tb.ball['position'].x, tb.ball['position'].y)
    # ball_vel = (tb.ball['velocity'].x, tb.ball['velocity'].y)
    pos0 = tb.ball['position'].y.__int__()
    # vel0 = tb.ball['velocity'].y.__int__()
    # op_card = tb.op_side['active_card']
    cards = tuple(tb.side['cards'])
    # tb_cards = tuple(tb.cards['cards'])
    # op_pos = ds['op_pos']
    # op_run = tb.op_side['run_vector']
    # op_life = tb.op_side['life']
    life = tb.side['life']
    deck = tb.side['cards']
    emptycard = Card('', None, None)
    deck.append(emptycard)

    # 计算使用卡片,如果有卡片就即刻使用;
    if cards is None:
        card = None
    else:
        card = cards[0]2

    # 计算迎球
    bat = tb.ball['position'].y - tb.side['position'].y

    # 计算跑位
    run = count_run(pos0, life)
    return RacketAction(tb.tick, bat, acc, run, None, card)


# 本函数在对局结束后调用，用于双方分析和保存历史数据
def summarize(tick: int, winner: str, reason: str, west: RacketData, east: RacketData, ball: BallData, ds: dict):
    return
