# -*- coding: utf-8 -*-
# @Author: Ren Qingjie
# @Date:   2017-05-24 02:46:14
# @Last Modified by:   Ren Qingjie
# @Last Modified time: 2017-05-24 13:29:48


# 导入程序包
from table import *
import math


# ==========Part1, 系统函数==========
# serve函数
def serve(ds: dict) -> tuple:
    return BALL_POS[1], BALL_V[1]


# play函数
def play(tb: TableData, ds: dict) -> RacketAction:
    return RacketAction(tb.tick, tb.ball['position'].y - tb.side['position'].y, 0, 0, None, None)


# 总结历史数据的函数
def summarize(tick: int, winner: str, reason: str, west: RacketData, east: RacketData, ball: BallData, ds: dict):
    return None


# ==========Part2, 基本函数==========
# 计算安全速度的函数, 利用发球时球的位置
def get_safe_v(pos, dim, vx) -> tuple:
    # 一次水平运动的时间
    t = abs((dim[1] - dim[0]) / vx)
    # 最大安全速度是折返2次（向上或者向下,取最大值）
    up_max_v = (3 * dim[3] - pos) / t - 1
    # 向下的速度取负值
    down_max_v = - ((2 * dim[3] + pos) / t - 1)
    max_v = up_max_v if (up_max_v > -down_max_v) else -down_max_v
    # 最小安全速度是折返1次（向上或者向下，取最小值）
    up_min_v = (dim[3] - pos) / t + 1
    down_min_v = -(pos / t + 1)
    min_v = up_min_v if (up_min_v < -down_min_v) else -down_min_v
    return max_v, min_v


# 根据每一个发球位置和球速计算球的落点状态(速度矢量和落点位置)
def get_ball(pos, dim, v) -> tuple:
    t = (dim[1] - dim[0]) / v[0]
    y_distance = v[1] * t
    # 落点的纵坐标
    get_pos_y = (pos + y_distance) % (dim[3])
    # 碰撞次数(即纵轴速度方向改变)
    get_bounce_time = (pos + y_distance) // dim[3]
    vy = v[1] * math.pow(-1, get_bounce_time)

    v = Vector(v[0], vy)
    # 结果是一个tuple, 元素分别为一个Vector和一个落点纵坐标
    return v, get_pos_y


# 计算球速函数，根据球的击球点和落点计算球的速度
def get_v(pos, op_pos, v, dim):
    # pos：己方击球点
    # op_pos: 对方球的落点
    # v: 触球时的球速,实际上只与vx有关
    # dim: 桌面坐标
    t = (dim[1] - dim[0]) / v[0]
    # y轴距离有4种情况
    diff = op_pos - pos  # 绝对距离
    y_distance = [diff + 2 * dim[3], diff +
                  dim[3], diff - dim[3], diff - 2 * dim[3]]
    return y_distance / t


# 计算成本函数，成本 =  移动消耗+触球改变速度消耗, d1为上次的跑位，d2为迎球跑动
# 计算移动消耗
def cost_run(distance, FD=FACTOR_DISTANCE):
    return abs(distance) ** 2 // FD ** 2


# 计算触球改变球速的消耗
def cost_acc(acc, FS=FACTOR_SPEED):
    return abs(acc) ** 2 // FS ** 2


# 计算为了将球击到特定位置的消耗(改变速度的消耗)
def cost_acc_pos(pos, op_pos, v: Vector, dim) -> tuple:
    # pos：自己触球时的位置
    # op_pos： 对方触球时的位置
    # v:自己触球时的球速
    # dim：桌面坐标

    acc_list = []  # 储存加速选择
    cost_acc_list = []  # 储存对应的消耗
    for i in get_v(pos, op_pos, v, dim):
        acc_list.append(i - v[1])
        cost_acc_list.append(cost_acc(i - v[1]))

    return acc_list, cost_acc_list
    # 得到一个tuple,第一个元素为加速方式的选择，第二个元素为对应的消耗


# 计算对方一次所产生的消耗
def cost_op(op_pos, op_next_pos, run, v: Vector, v_next: Vector, dim):
    # op_pos:上次对方触球时的位置
    # op_next_pos：本次对方触球时的位置（迎球位置）
    # run：对方的跑位距离（矢量）,需要通过预测产生
    # v:我方触球后的球速
    # v_next：对方触球后的球速
    return cost_run(run) + cost_run(op_next_pos - op_pos) + cost_acc(v_next[1] - v[1])


# 计算一次的消耗
def cost(d1, d2, acc, FD=FACTOR_DISTANCE, FS=FACTOR_SPEED):
    # d1: 上一次的跑位距离
    # d2：迎球距离
    # acc:触球改变球速大小

    # cost1 = abs(d1) ** 2 // FD ** 2
    # cost2 = abs(d2) ** 2 // FD ** 2
    # cost3 = abs(acc) ** 2 // FS ** 2
    # return cost1 + cost2 + cost3
    return cost_run(d1) + cost_run(d2) + cost_acc(acc)


# ==========Part3, 策略函数==========
# 跑位策略：跑位到预期落点的一半距离
def count_run(pos, next_pos):
    # pos: 当前球拍位置
    # next_pos:下一期的触球位置（预期）

    return (pos + next_pos) // 2


# 触球策略1：最大化一次击球收益
def count_acc1():
    pass
    # cost_self = cost(d1, d2, acc)
    # cost_op = cost(op_d1, op_d2, op_acc)
    # return acc;


# 触球策略2：固定打角
def count_acc2(pos, v: Vector, dim):
    # pos： 触球时的位置
    # v： 触球时QQ的速度
    # dim: 桌面坐标

    cost_corner1 = cost_acc_pos(pos, dim[3], v, dim)
    cost_corner2 = cost_acc_pos(pos, dim[2], v, dim)

    # 击球到某个固定点的收益
    benefit = []
    # 对每个加速度进行遍历
    # for i in [cost_corner1+cost_corner2][0]:
        # benefit.append(cost_op())
    return


# 迎球策略：（一定要接到球啊，迎球有个毛线策略）
def count_bat(pos, op_pos, op_v):
    # pos: 迎球开始时自己的位置
    # op_pos: 对方发球时的位置
    # op_v：对方发球时球的速度

    distance = get_ball(op_pos, op_v) - pos
    # # 迎球方向
    # bat_direction = sign(distance)
    # # 迎球距离
    # bat_distance = abs(distance)
    # bat_vector = Vector(bat_direction, bat_distance)
    # return bat_vector
    return Vector(sign(distance), abs(distance))


# 预测对方跑位行为：(得到对方跑位结束后的预测位置)
def get_op_run():
    pass


# 预测对方触球行为：(得到对方触球改变速度的加速矢量)
def get_op_acc():
    pass
