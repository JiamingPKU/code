# to do: 1. 优化道具价值 4. 优化对方加速花费 6. 考虑道具容量
# 7. 改进搜索算法 8. 改进发球算法
# Change log: 0.11 - bugfix
# 0.2 - 加入了储存信息
# 0.3 - bugfix; 修正了球撞球拍的速度变化; 修正了球撞墙的速度变化
# 0.4 - 可以用道具啦！....跑位暂时往中间跑先，接下来该上学习了
# 0.5 - 斩杀与被斩杀的研究
from table import *
import sys

# 参数设定
tick_step = (DIM[1] - DIM[0]) // BALL_V[0]
serve_para = 'upmax'
card_value = {'SP': 400, 'DS': 10, 'IL': 4000, 'DL': 4010, 'TP': 2000, 'AM': 4000}
# 使用道具花费
card_savevalue = {'SP': 200, 'DS': -10, 'IL': 1970, 'DL': 1960, 'TP': 980, 'AM': 1000, '': 0}


# 安全速度计算
def secureVelocity(pos):
    up_ub = (DIM[3] * 3 - pos) // tick_step
    up_lb = (DIM[3] - pos) // tick_step
    down_lb = - ((DIM[3] * 2 + pos) // tick_step)
    down_ub = - (pos // tick_step)
    return [up_ub, up_lb, down_ub, down_lb]


# 判断速度是否安全
def issecure(pos, vel):
    sec = secureVelocity(pos)
    if vel >= sec[0] or vel <= sec[3]:
        return False
    if vel <= sec[1] and vel >= sec[2]:
        return False
    return True


# 预测落点
def predictpos_op(pos, vel):
    if not issecure(pos, vel):
        return -1
    return (pos + vel * tick_step) % DIM[3]

# 预测对方速度
def predictvel_op(pos,vel):
    op_vel = -vel
    if vel >= (2 * DIM[3] - pos) / tick_step or vel <= - (pos + DIM[3]) / tick_step:
        op_vel = - op_vel
    return op_vel


# 预测击回时落点
def predictpos_back(pos, vel):
    op_pos = predictpos_op(pos, vel)
    op_vel = predictvel_op(pos,vel)
    if issecure(op_pos, op_vel):
        return predictpos_op(op_pos, op_vel)
    sec = secureVelocity(op_pos)
    if op_vel >= sec[0]:
        return DIM[3]
    if op_vel <= sec[3]:
        return 0
    if op_vel <= sec[1] and op_vel > 0:
        return DIM[3]
    return 0


# 发球函数，总是做为West才发球
# ds为函数可以利用的存储字典
# 函数需要返回球的y坐标，和y方向的速度
def serve(ds: dict) -> tuple:
    # 发球模式：向上最大
    initialize(ds)
    if serve_para == 'upmax':
        sec = secureVelocity(0)
        return 0, sec[0] - 1
    return BALL_POS[1], BALL_V[1]


def initialize(ds: dict):
    ds['op_pos'] = (DIM[3]-DIM[2])//2
    ds['op_prevpos'] = (DIM[3]-DIM[2])//2
    ds['op_prevlife'] = RACKET_LIFE


# 打球函数
# tb为TableData类型的对象
# ds为函数可以利用的存储字典
# 函数需要返回一个RacketAction对象
def play(tb: TableData, ds: dict) -> RacketAction:
    tick_step = tb.step
    turns = tb.tick // (2 * tb.step) + 1
    firstturn=False
    if turns == 1:
        initialize(ds)
        firstturn = True
    # 参数
    vbond = secureVelocity(tb.ball['position'].y)
    vel0 = tb.ball['velocity'].y
    pos0 = tb.ball['position'].y
    op_card = tb.op_side['active_card']
    cards = tb.side['cards']
    tb_cards = tb.cards['cards']
    op_pos = ds['op_pos']
    op_run = tb.op_side['run_vector']
    op_life = tb.op_side['life']
    life = tb.side['life']

    # 测试运行结果
    def testrun(action):
        ball1 = Ball(DIM, tb.ball['position'], tb.ball['velocity'])
        # 旋转球不在这里实现
        ball1.update_velocity(action.acc, None)
        ball1.bounce_racket()
        count_bounce, hit_cards = ball1.fly(tick_step, tb.cards['cards'])
        return count_bounce, hit_cards, ball1

    # 核心函数1：赋值函数
    # 暂时不考虑体力限制先.......
    def evaluation(pos, vel, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, run, use_card):
        cost = 0
        # 加速花费
        acc_cost = (acc / FACTOR_SPEED) ** 2
        cost += acc_cost
        life -= acc_cost
        if op_card[1] == CARD_SPIN:
            acc = acc * CARD_SPIN_PARAM
        # 跑位花费
        run_cost = (run / FACTOR_DISTANCE) ** 2
        cost += run_cost
        life -= run_cost
        # 对方击球花费
        # 先用对方最小消耗吧
        target_pos = predictpos_op(pos, vel + acc)
        if op_run is None or (target_pos - op_pos) * op_run > 0:
            op_run_cost = ((target_pos - op_pos) / FACTOR_DISTANCE) ** 2 / 4
            op_hit_cost = ((target_pos - op_pos) / FACTOR_DISTANCE) ** 2 / 4
        else:
            op_run_cost = 0
            op_hit_cost = ((target_pos - op_pos) / FACTOR_DISTANCE) ** 2
        cost = cost - op_run_cost - op_hit_cost
        # op_life = op_life - op_run_cost - op_hit_cost
        # 对方加速花费
        # 先只管安全速度
        op_sec = secureVelocity(target_pos)
        op_vel = predictvel_op(pos, vel + acc)
        op_acc_cost = 0
        if not issecure(target_pos, op_vel):
            if op_vel >= op_sec[0]:
                op_acc_cost = ((op_vel - op_sec[0]) / FACTOR_SPEED) ** 2
            if op_vel <= op_sec[3]:
                op_acc_cost = ((op_vel - op_sec[3]) / FACTOR_SPEED) ** 2
            if op_vel <= op_sec[1] and op_vel > 0:
                op_acc_cost = ((op_vel - op_sec[1]) / FACTOR_SPEED) ** 2
            if op_vel >= op_sec[2] and op_vel < 0:
                op_acc_cost = ((op_vel - op_sec[2]) / FACTOR_SPEED) ** 2
        cost -= op_acc_cost
        # op_life -= op_acc_cost
        # 我方下次击球花费
        # 先按对方不改变速度估计好了，这个一定要学习....
        cost += ((predictpos_back(pos, vel + acc) - pos - run) / FACTOR_DISTANCE) ** 2
        # 捡道具花费，假装不会捡满先.......
        action = RacketAction(tb.tick, tb.ball['position'].y - tb.side['position'].y, acc, 0, None, None)
        c_bounce, hit_cards, ball = testrun(action)
        for card in hit_cards:
            cost -= card_value[card.code]
        cost += card_savevalue[use_card]
        # 使用道具
        if use_card == 'SP':
            cost -= op_acc_cost * 3
            # op_life -= op_acc_cost * 3
        if use_card == 'IL':
            cost -= 2000
        if use_card == 'DL':
            cost -= 2000
            op_life -= 2000
        if use_card == 'TP':
            cost -= run_cost
            new_runcost=(max(run - CARD_TLPT_PARAM, 0) / FACTOR_DISTANCE) ** 2
            cost += new_runcost
            life += run_cost
            life -= new_runcost
        if use_card == 'AM':
            cost -= op_hit_cost
        # 斩杀系统
        op_max_distance = op_life / RACKET_LIFE * BALL_V[1] * tick_step
        if op_max_distance < DIM[3]:
            if op_run is None or (target_pos - op_pos) * op_run > 0:
                if (target_pos - op_pos) > 2 * op_max_distance:
                    cost -= sys.maxsize
            else:
                if (target_pos - op_pos) > op_max_distance:
                    cost -= sys.maxsize
        # 防斩杀系统
        pass

        return cost

    # 核心函数2：寻找最优解函数
    # 使用道具
    deck = tb.side['cards']
    emptycard=Card('',None,None)
    deck.append(emptycard)
    for card_using in deck:
        card_code=card_using.code
        if op_card[1] != CARD_SPIN:
            for acc in range(vbond[1] - vel0, vbond[0] - vel0):
                if evaluation(pos0, vel0, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, 0, card_code) < costmin:
                    accmin = acc
                    costmin = evaluation(pos0, vel0, tb_cards, op_pos, op_run, op_card, cards, acc, 0, card_code)
            for acc in range(vbond[3] - vel0, vbond[2] - vel0):
                if evaluation(pos0, vel0, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, 0, card_code) < costmin:
                    accmin = acc
                    costmin = evaluation(pos0, vel0, tb_cards, op_pos, op_run, op_card, cards, acc, 0, card_code)
        else:
            for acc in range((vbond[1] - vel0) // CARD_SPIN_PARAM, (vbond[0] - vel0) // CARD_SPIN_PARAM):
                if evaluation(pos0, vel0, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, 0, card_code) < costmin:
                    accmin = acc
                    costmin = evaluation(pos0, vel0, tb_cards, op_pos, op_run, op_card, cards, acc, 0, card_code)
            for acc in range((vbond[3] - vel0) // CARD_SPIN_PARAM, (vbond[2] - vel0) // CARD_SPIN_PARAM):
                if evaluation(pos0, vel0, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, 0, card_code) < costmin:
                    accmin = acc
                    costmin = evaluation(pos0, vel0, tb_cards, op_pos, op_run, op_card, cards, acc, 0, card_code)

    # # 暴力搜索跑位
    # runmin = 0
    # for run in range(-pos0, DIM[3] - pos0):
    #     if evaluation(pos0, vel0, tb_cards, op_pos, op_run, op_card, cards, accmin, run, '') < costmin:
    #         runmin = run
    #         costmin = evaluation(pos0, vel0, tb_cards, op_pos, op_run, op_card, cards, accmin, run, '')

    pass
    # 储存信息
    op_nextpos=predictpos_op(pos0,vel0+accmin)
    # 先不管道具
    if not firstturn:
        ds['op_prevrun'] = 0
        ds['op_prevacc'] = vel0 + ds['prevvel']
    ds['op_prevlife'] = op_life
    ds['op_pos'] = op_nextpos
    ds['op_prevpos'] = op_pos
    ds['prevvel'] = vel0 + accmin
    # 学习
    pass
    return RacketAction(tb.tick, pos0 - tb.side['position'].y, accmin, (DIM[3] - DIM[2]) // 2 - tb.ball['position'].y, None, None)


# 对局后保存历史数据函数
# ds为函数可以利用的存储字典
# 本函数在对局结束后调用，用于双方分析和保存历史数据
def summarize(tick: int, winner: str, reason: str, west: RacketData, east: RacketData, ball: BallData, ds: dict):
    return
