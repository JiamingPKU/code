# to do: 1. 优化道具价值 4. 优化对方加速花费 6. 考虑道具容量
# 7. 改进搜索算法 8. 改进发球算法
# Change log: 0.11 - bugfix
# 0.2 - 加入了储存信息
# 0.3 - bugfix; 修正了球撞球拍的速度变化; 修正了球撞墙的速度变化
# 0.4 - 可以用道具啦！....跑位暂时往中间跑先，接下来该上学习了
# 0.5 - 斩杀与被斩杀的研究, bugfix - 传输使用道具
# 0.51 - bugfix - 修正了道具的问题（glwang
# 0.6 - bugfix; 改进了搜索
# 安全速度预测落点版本。修改包括： (line29)增加了count_run函数,计算安全速度返回的落点; (line172)赋值函数进行了修改，去掉run作为参数输入，而是作为内部变量。同时在(line252)注释掉了跑位到中间的赋值。(line386)增加了返回结果前的run的计算。
from table import *
import sys
import copy

# 参数设定
tick_step = (DIM[1] - DIM[0]) // BALL_V[0]
serve_para = 'upmax'
card_value = {'SP': 4000, 'DS': 10, 'IL': 4000,
              'DL': 4010, 'TP': 2000, 'AM': 1000}
# 使用道具花费
card_savevalue = {'SP': 1000, 'DS': -10, 'IL': 1970,
                  'DL': 1960, 'TP': 500, 'AM': 500, '': 0}
# 搜索初始步长
step = 100


# 计算跑位距离,跑位到预测落点位置的一半
def count_run(pos, vel):
    # pos: 触球后自己的位置
    # vel: 触球后的球速
    # 计算预测落点以及距离
    pos_back = predictpos_back(pos, vel)
    predictDistance = pos_back - pos
    # 如果距离预测落点很近，那么反向跑位迷惑对方
    # 需要解决一个小bug,如果跑出桌面。不过可能比较少发生。
    if abs(predictDistance) < 100:
        run = - (predictDistance - pos) // 2
    # 否则，跑位到预测落点的一半位置
    else:
        run = (predictDistance - pos) // 2
    return run


# 安全速度计算
def secureVelocity(pos):
    up_ub = (DIM[3] * 3 - pos) // tick_step
    up_lb = (DIM[3] - pos) // tick_step
    down_lb = - ((DIM[3] * 2 + pos) // tick_step)
    down_ub = - (pos // tick_step)
    return [up_ub.__int__(), up_lb.__int__(), down_ub.__int__(), down_lb.__int__()]


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
    if predictvel_op(pos, vel) == vel:
        return (pos + vel * tick_step) % DIM[3]
    else:
        return DIM[3] - ((pos + vel * tick_step) % DIM[3])


# 预测对方速度
def predictvel_op(pos, vel):
    # pos: 我方击球速度
    # vel: 我方击球速度
    # pos_op = predictpos_op(pos, vel)

    op_vel = -vel
    if vel >= (2 * DIM[3] - pos) / tick_step or vel <= - (pos + DIM[3]) / tick_step:
        op_vel = - op_vel
    return op_vel


# 预测击回时落点
def predictpos_back(pos, vel):
    op_pos = predictpos_op(pos, vel)
    op_vel = predictvel_op(pos, vel)
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
def serve(op_side: str, ds: dict) -> tuple:
    # 发球模式：向上最大
    initialize(ds)
    if serve_para == 'upmax':
        sec = secureVelocity(0)
        return 0, sec[0] - 1
    return BALL_POS[1], BALL_V[1]


def initialize(ds: dict):
    ds['op_pos'] = (DIM[3] - DIM[2]) // 2
    ds['op_prevpos'] = (DIM[3] - DIM[2]) // 2
    ds['op_prevlife'] = RACKET_LIFE


# 打球函数
# tb为TableData类型的对象
# ds为函数可以利用的存储字典
# 函数需要返回一个RacketAction对象
def play(tb: TableData, ds: dict) -> RacketAction:
    tick_step = tb.step
    turns = tb.tick // (2 * tb.step) + 1
    firstturn = False
    if turns == 1:
        initialize(ds)
        firstturn = True
    # 参数
    vbond = secureVelocity(tb.ball['position'].y)
    ball_pos = (tb.ball['position'].x, tb.ball['position'].y)
    ball_vel = (tb.ball['velocity'].x, tb.ball['velocity'].y)
    pos0 = tb.ball['position'].y.__int__()
    vel0 = tb.ball['velocity'].y.__int__()
    op_card = tb.op_side['active_card']
    cards = tuple(tb.side['cards'])
    tb_cards = tuple(tb.cards['cards'])
    op_pos = ds['op_pos']
    op_run = tb.op_side['run_vector']
    op_life = tb.op_side['life']
    life = tb.side['life']

    # 测试运行结果
    def testrun(action, cards):
        ball1 = Ball(DIM, Vector(ball_pos[0], ball_pos[
                     1]), Vector(ball_vel[0], ball_vel[1]))
        # 旋转球不在这里实现
        ball1.update_velocity(action.acc, [None, None])
        ball1.bounce_racket()
        count_bounce, hit_cards = ball1.fly(tick_step, list(cards))
        return count_bounce, hit_cards, ball1

    # 核心函数1：赋值函数
    # 暂时不考虑体力限制先.......
    # 这里把run作为已知值，下面把跑位作为函数的一部分带入
    def evaluation(pos, vel, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, use_card):
        if not issecure(pos, vel + acc):
            return sys.maxsize
        cost = 0
        # life = copy.deepcopy(tb.side['life'])
        # op_life = copy.deepcopy(tb.op_side['life'])
        # 加速花费
        acc_cost = (acc / FACTOR_SPEED) ** 2
        cost += acc_cost
        # life -= acc_cost
        if op_card[1] == CARD_SPIN:
            acc = acc * CARD_SPIN_PARAM
        # 跑位花费
        # 增加了count_run函数
        run = count_run(pos, vel)
        run_cost = (run / FACTOR_DISTANCE) ** 2
        cost += run_cost
        # life -= run_cost
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
        # cost += ((predictpos_back(pos, vel + acc) - pos - run) / FACTOR_DISTANCE) ** 2
        # 捡道具花费，假装不会捡满先.......
        action = RacketAction(
            tb.tick, tb.ball['position'].y - tb.side['position'].y, acc, 0, None, None)
        c_bounce, hit_cards, ball = testrun(action, tb_cards)
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
            # op_life -= 2000
        if use_card == 'TP':
            cost -= run_cost
            new_runcost = (max(run - CARD_TLPT_PARAM, 0) /
                           FACTOR_DISTANCE) ** 2
            cost += new_runcost
            # life += run_cost
            # life -= new_runcost
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
    emptycard = Card('', None, None)
    deck.append(emptycard)
    costmin = sys.maxsize

    # 取消了这里的定义的run
    # run = (DIM[3] - DIM[2]) // 2 - pos0

    # run = count_run( ,pos0)
    # for card_using in deck:
    #     card_code = card_using.code
    #     if op_card[1] != CARD_SPIN:
    #         for acc in range(vbond[1] - vel0 + 1, vbond[0] - vel0 - 1):
    #             cost1 = evaluation(pos0, vel0, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, run, card_code)
    #             if cost1 < costmin:
    #                 accmin = acc
    #                 cardmin = card_using
    #                 costmin = cost1
    #         for acc in range(vbond[3] - vel0 + 1, vbond[2] - vel0 - 1):
    #             cost1 = evaluation(pos0, vel0, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, run, card_code)
    #             if cost1 < costmin:
    #                 accmin = acc
    #                 cardmin = card_using
    #                 costmin = cost1
    #     else:
    #         for acc in range(((vbond[1] - vel0) // CARD_SPIN_PARAM).__int__() + 2, ((vbond[0] - vel0) // CARD_SPIN_PARAM).__int__() - 2):
    #             cost1 = evaluation(pos0, vel0, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, run, card_code)
    #             if cost1 < costmin:
    #                 accmin = acc
    #                 cardmin = card_using
    #                 costmin = cost1
    #         for acc in range(((vbond[3] - vel0) // CARD_SPIN_PARAM).__int__() + 2, ((vbond[2] - vel0) // CARD_SPIN_PARAM).__int__() - 2):
    #             cost1 = evaluation(pos0, vel0, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, run, card_code)
    #             if cost1 < costmin:
    #                 accmin = acc
    #                 cardmin = card_using
    #                 costmin = cost1

    def searchaccrange(start, stop, step, paras):
        p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 = paras
        if stop - start < 25:
            accs = list(range(start, stop + 1))
            costs = [evaluation(p1, p2, p3, p4, p5, p6, p7, p8,
                                p9, accforsearch, p10, p11) for accforsearch in accs]
            mincost = min(costs)
            minaccindex = costs.index(mincost)
            return accs[minaccindex], mincost
        accs = list(range(start, stop, step))
        accs.append(stop)
        costs = [(evaluation(p1, p2, p3, p4, p5, p6, p7, p8, p9,
                             accforsearch, p10, p11)) for accforsearch in accs]
        costssorted = copy.copy(costs)
        costssorted.sort()
        mincosts = [costssorted[0], costssorted[1]]
        minaccindex = [costs.index(mincosts[0]), costs.index(mincosts[1])]
        if minaccindex[0] == minaccindex[1]:
            minaccindex[1] = costs.index(
                mincosts[1], costs.index(mincosts[0]) + 1)
        minaccindex.sort()
        minacc = [accs[minaccindex[0]], accs[minaccindex[1]]]
        if minacc[1] - minacc[0] != step:
            a1, costa1 = searchaccrange(
                minacc[0] - step, minacc[0] + step, step // 5, paras)
            a2, costa2 = searchaccrange(
                minacc[1] - step, minacc[1] + step, step // 5, paras)
            if costa1 < costa2:
                return a1, costa1
            else:
                return a2, costa2
        return searchaccrange(minacc[0], minacc[1], (minacc[1] - minacc[0]) // 10, paras)

    costmin = sys.maxsize
    for card_using in deck:
        card_code = card_using.code
        # print(card_code)
        # 不捡道具模式
        paras = [pos0, vel0, life, op_life, (), op_pos, op_run,
                 op_card, cards, run, card_code]
        if op_card[1] != CARD_SPIN:
            a1, costa1 = searchaccrange(
                vbond[1] - vel0 + 1, vbond[0] - vel0 - 1, step, paras)
            a2, costa2 = searchaccrange(
                vbond[3] - vel0 + 1, vbond[2] - vel0 - 1, step, paras)
        else:
            a1, costa1 = searchaccrange(((vbond[1] - vel0) // CARD_SPIN_PARAM).__int__() + 2,
                                        ((vbond[0] - vel0) // CARD_SPIN_PARAM).__int__() - 2, step, paras)
            a2, costa2 = searchaccrange(((vbond[3] - vel0) // CARD_SPIN_PARAM).__int__() + 2,
                                        ((vbond[2] - vel0) // CARD_SPIN_PARAM).__int__() - 2, step, paras)
        if costa1 < costmin:
            costmin = costa1
            accmin = a1
            cardmin = card_using
        if costa2 < costmin:
            costmin = costa2
            accmin = a2
            cardmin = card_using
        # 捡道具模式
        for card in tb_cards:
            cardx = card.pos.x - tb.ball['position'].x
            cardy = card.pos.y
            y1 = 2 * DIM[3] - cardy - pos0
            y2 = 2 * DIM[3] + cardy - pos0
            y3 = - cardy - pos0
            y4 = - 2 * DIM[3] + cardy - pos0
            y5 = cardy - pos0
            ycards = [y1, y2, y3, y4, y5]
            velcards = [(yy / (abs(cardx)) * BALL_V[0]).__int__()
                        for yy in ycards]
            acccards = [v - vel0 for v in velcards if issecure(pos0, v)]
            if len(acccards) > 0:
                costs = [evaluation(pos0, vel0, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, (DIM[
                                    3] - DIM[2]) // 2 - pos0, card_code) for acc in acccards]
                mincardcost = min(costs)
                if mincardcost < costmin:
                    costmin = mincardcost
                    accmin = acccards[costs.index(costmin)]
                    cardmin = card_using
        # print(cardmin.code)
    pass
    # # 暴力搜索跑位
    # runmin = 0
    # for run in range(-pos0, DIM[3] - pos0):
    #     if evaluation(pos0, vel0, tb_cards, op_pos, op_run, op_card, cards, accmin, run, '') < costmin:
    #         runmin = run
    #         costmin = evaluation(pos0, vel0, tb_cards, op_pos, op_run, op_card, cards, accmin, run, '')

    pass
    # 储存信息
    op_nextpos = predictpos_op(pos0, vel0 + accmin)
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
    # 增加了跑位的计算
    run = count_run(pos0, vel0 + accmin)
    return RacketAction(tb.tick, pos0 - tb.side['position'].y, accmin, run, None, cardmin)


# 对局后保存历史数据函数
# ds为函数可以利用的存储字典
# 本函数在对局结束后调用，用于双方分析和保存历史数据
def summarize(tick: int, winner: str, reason: str, west: RacketData, east: RacketData, ball: BallData, ds: dict):
    return
