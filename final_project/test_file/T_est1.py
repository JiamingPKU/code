# -*- coding: utf-8 -*-
# @Author: Ren Qingjie
# @Date:   2017-05-24 02:46:14
# @Last Modified by:   Ren Qingjie
# @Last Modified time: 2017-05-27 01:57:25


# 导入程序包
from table import *
import math


# ==========Part1, 系统函数==========
# serve函数
def serve(ds: dict) -> tuple:
    return BALL_POS[1], BALL_V[1]


# play函数
def play(tb: TableData, ds: dict) -> RacketAction:

    # 引入参数
    ball_pos = tb.ball["position"].y
    op_pos = tb.op_side["position"].y
    pos = tb.side["position"].y
    op_v = tb.ball["velocity"]
    dim = DIM


    bat_vector = count_bat(pos, op_pos, op_v, dim)
    return RacketAction(tb.tick, bat_vector, 0, 0, None, None)

    # bat_vector = ball_pos - pos
    # return RacketAction(tb.tick, tb.ball['position'].y -
    # tb.side['position'].y, 0, 0, None, None)
    # bat_vector = ball_pos - pos
    # return RacketAction(tb.tick, bat_vector, 0, 0, None, None)


# 总结历史数据的函数
def summarize(tick: int, winner: str, reason: str, west: RacketData, east: RacketData, ball: BallData, ds: dict):
    return None


# ==========Part2, 基本函数==========
# 计算安全速度的函数, 利用发球时球的位置
def get_safe_v(pos, v, dim) -> tuple:
    # pos:球的位置
    # v:球速
    # dim: 桌面大小

    # 一次水平运动的时间
    vx = v.x
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
def get_ball(pos, v: Vector, dim) -> tuple:
    # pos： 触球位置
    # v: 球速
    # dim: 桌面
    t = (dim[1] - dim[0]) / v.x
    y_distance = v.x * t
    # 落点的纵坐标
    get_pos_y = int(pos + y_distance) % (dim[3])
    # 碰撞次数(即纵轴速度方向改变)
    get_bounce_time = (pos + y_distance) // dim[3]
    vy = v.y * math.pow(-1, get_bounce_time)

    v = Vector(v.x, vy)
    # 结果是一个tuple, 元素分别为一个Vector和一个落点纵坐标
    return v, get_pos_y


# 计算球速函数，根据球的击球点和落点计算球的速度
def get_v(pos, op_pos, v, dim):
    # pos：己方击球点
    # op_pos: 对方球的落点
    # v: 触球时的球速,实际上只与vx有关
    # dim: 桌面坐标
    t = (dim[1] - dim[0]) / v.x
    # y轴距离有4种情况
    diff = op_pos - pos  # 绝对距离
    y_distance = [diff + 2 * dim[3], diff +
                  dim[3], diff - dim[3], diff - 2 * dim[3]]
    return y_distance / t


# 计算成本函数，成本=移动消耗+触球改变速度消耗
# 计算移动消耗
def cost_run(distance, FD=FACTOR_DISTANCE):
    # distance: 移动距离
    return abs(distance) ** 2 // FD ** 2


# 计算触球改变球速的消耗
def cost_acc(acc, FS=FACTOR_SPEED):
    # acc:改变球速大小
    return abs(acc) ** 2 // FS ** 2


# 计算为了将球击到特定位置的消耗(改变速度的消耗)
def cost_acc_pos(pos, op_pos, v: Vector, dim) -> dict:
    # pos：自己触球时的位置
    # op_pos： 对方触球时的位置
    # v:自己触球时的球速
    # dim：桌面坐标

    cost_acc_list = {}  # 储存加速度及对应的消耗
    for i in get_v(pos, op_pos, v, dim):
        acc_list.append(i - v.y)
        cost_acc_list[i] = cost_acc(i - v.y)

    return cost_acc_list
    # 得到一个dict,key为加速度大小，value为对应的消耗


# 计算一次的消耗
def cost(pos, pos_last, run, acc, FD=FACTOR_DISTANCE, FS=FACTOR_SPEED):
    # pos:触球时的位置
    # pos_last:上一次触球时的位置
    # run:跑位距离
    # acc:触球改变球速大小

    cost_total = cost_run(run) + cost_run(pos - pos_last - run) + cost_acc(acc)
    return cost_total


# ==========Part3, 策略函数==========
# 跑位策略：跑位到预期落点的一半距离
def count_run(pos, next_pos):
    # pos: 当前球拍位置
    # next_pos:下一期的触球位置（预期）

    run_vector = (pos + next_pos) // 2 - pos
    # 得到跑位的矢量
    return run_vector


# 触球策略1：最大化一次击球收益
def count_acc1():
    return acc1


# 触球策略2：固定打角
def count_acc2(pos, v: Vector, allPublicInfo, dim, ds):
    # pos： 触球时的位置
    # v： 触球时球的速度
    # allPublicInfo：历史共同信息
    # dim: 桌面坐标

    # 从公共信息中获取变量
    PublicInfo = allPublicInfo[-1]
    op_pos_last = PublicInfo.op_pos
    # op_run_last = PublicInfo.op_run
    pos_last = PublicInfo.pos
    run_last = PublicInfo.run
    op_v_last = PublicInfo.op_v

    # 固定打角的成本
    cost_corner1 = cost_acc_pos(pos, dim[3], v, dim)
    cost_corner2 = cost_acc_pos(pos, dim[2], v, dim)
    cost_corner = cost_corner1 + cost_corner2

    # 击球到某个固定点的预期对方消耗，下面计算这个字典
    op_cost_dict = {}

    # 对每个加速度进行遍历,获得对方的预期行为和预期消耗
    for i in cost_corner:
        # 对方触球前（刚刚迎到球）时的球速与球的落点坐标
        op_v = get_ball(pos, v + i, dim)[0]
        op_pos = get_ball(pos, v + i, dim)[1]
        # 对方的跑位
        op_run = get_op_run(pos_last, run_last,
                            op_pos_last, op_v_last, dim, ds)
        # 对方触球的加速度
        op_acc = get_op_acc(op_v, op_pos, pos_last, run_last, dim, ds)

        # 总消耗
        op_cost = cost(op_pos, op_pos_last, op_run, op_acc)
        op_cost_dict[i] = op_cost

    # 固定打角的净收益
    benefits = {}
    for i in cost_corner:
        benefits[i] = op_cost_dict[i] - cost_corner[i]

    # 计算最大收益及对应的加速度
    max_benefit = max(zip(benefits.values(), benefits.keys()))
    # max_benefit_value = max_benefit[0]
    acc2 = max_benefit[1]
    return acc2


# 迎球策略：（一定要接到球啊，迎球有个毛线策略）
def count_bat(pos, op_pos, op_v, dim):
    # pos: 迎球开始时自己的位置
    # op_pos: 对方发球时的位置
    # op_v：对方发球时球的速度

    bat_vector = get_ball(op_pos, op_v, dim)[1] - pos
    # 迎球运动矢量
    return bat_vector


# ==========Part4, 预测函数==========
# 一期的共同信息，主要用来预测对方的行为
class publicInfo:

    def __init__(self, pos, run, op_pos, op_run, v: Vector, op_v: Vector):
        self.pos = pos  # 自己的触球位置
        self.run = run  # 自己的跑位方向
        self.op_pos = op_pos  # 对方的触球位置
        self.op_run = op_run  # 对方的跑位方向
        self.v = v  # 自己触球后球速
        self.op_v = op_v  # 对方触球后球速

    # 更新
    def getNew(self, pos, run, op_pos, op_run, v: Vector, op_v: Vector):
        self.pos = pos
        self.run = run
        self.op_pos = op_pos
        self.op_run = op_run
        self.v = v
        self.op_v = op_v


# 所有期的共同信息
class allPublicInfo(list):

    # 定义共同信息的更新
    def update(self, newInfo):
        pub_Info = None if (self == []) else self[-1]
        pub_Info.getNew(newInfo)
        self.append(pub_Info)


# 预测对方跑位行为：(得到对方跑位结束后的预测位置)
def get_op_run(pos_last, run_last, op_pos_last, op_v_last: Vector, dim, ds):
    # pos_last: 对方触球时观测到我方的位置（应该是上一次的我方触球位置）
    # run_last：对方触球时观测到我方的跑位情况（应该是上一次的我方跑位情况）
    # op_pos_last: 对方上一次触球位置
    # op_v_last: 对方上一次触球后的球速（可以预期球的我方落点）
    # dim:桌面大小
    # ds：其他历史信息

    op_run = (dim[3] + dim[2]) / 2 - op_pos
    return op_run


# 预测对方触球行为：(得到对方触球改变速度的加速矢量)
def get_op_acc(op_v: Vector, op_pos, pos_last, run_last, dim, ds):
    # op_v:对方触球前的球速
    # op_pos：对方触球时的球的位置
    # pos_last: 我方上一次的位置
    # run_last：我方上一次的跑位

    op_acc = predict_acc()
    return op_acc
