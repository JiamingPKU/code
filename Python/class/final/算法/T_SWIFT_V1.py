from table import *
import sys
import copy
import random

# 参数
tick_step = (DIM[1] - DIM[0]) // BALL_V[0]
card_value = {'SP': 2000, 'DS': 10, 'IL': 4000, 'DL': 4010, 'TP': 400, 'AM': 2000}


# 临界速度计算
def vel_critical(pos):
    up_ub = int((DIM[3] * 3 - pos) / tick_step) - 1
    up_mid = int((DIM[3] * 2 - pos) / tick_step) + 1
    up_lb = int((DIM[3] - pos) / tick_step) + 1
    down_lb = -int((DIM[3] * 2 + pos) / tick_step) + 1
    down_mid = -int((DIM[3] + pos) / tick_step) - 1
    down_ub = -int(pos / tick_step) - 1
    return [[up_lb, up_mid, up_ub], [down_lb, down_mid, down_ub]]


# 判断击球是否合法
def isLegal(pos, vel):
    crit = vel_critical(pos)
    if vel > crit[0][2] or vel < crit[1][0] or crit[1][2] < vel < crit[0][0]:
        return False
    else:
        return True


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


# 预测击回时落点
# def predictpos_back(pos, vel):
#     op_pos = predictpos_op(pos, vel)
#     op_vel = predictvel_op(pos, vel)
#     if issecure(op_pos, op_vel):
#         return predictpos_op(op_pos, op_vel)
#     sec = secureVelocity(op_pos)
#     if op_vel >= sec[0]:
#         return DIM[3]
#     if op_vel <= sec[3]:
#         return 0
#     if 0 < op_vel <= sec[1]:
#         return DIM[3]
#     return 0

def serve(op_side: str, ds: dict) -> tuple:
    return BALL_POS[1], random.randrange(500, BALL_V[1])


def play(tb: TableData, ds: dict) -> RacketAction:
    # 参数
    bat = tb.ball['position'].y - tb.side['position'].y
    routes = []

    # 测试运行结果，返回bounces, cards_hit, test_ball
    def test(action):
        test_ball = Ball(DIM, copy.deepcopy(tb.ball['position']), copy.deepcopy(tb.ball['velocity']))
        test_ball.update_velocity(action.acc, copy.deepcopy(tb.op_side['active_card']))
        test_ball.bounce_racket()
        return test_ball.fly(tick_step, copy.deepcopy(tb.cards['cards']))

    class Route:
        def __init__(self, start, vel0, action, mode):
            self.start = start
            self.vel0 = vel0
            self.end = get_op_pos(self.start, self.vel0)
            self.action = action
            self.mode = mode
            self.cards = test(self.action)[1]

        def isLegal(self):
            return isLegal(self.start, self.vel0)

        def getEnd(self):
            return self.end

        def getCards(self):
            return self.cards

    def hit_corners():
        crit = vel_critical(tb.ball['position'].y)
        for i in range(0, 2):
            for j in range(0, 3):
                new_action = RacketAction(tb.tick, bat, crit[i][j] - tb.ball['velocity'].y, None, None, None)
                if tb.op_side['active_card'][1] == 'SP':
                    new_action.acc = int(new_action.acc / CARD_SPIN_PARAM)
                new_route = Route(tb.ball['position'].y, crit[i][j], new_action, 'HIT_CORNERS')
                routes.append(new_route)

    def hit_cards():
        for card in tb.cards['cards']:
            t0 = abs((tb.ball['position'].x - card.pos.x) // BALL_V[0])
            vel_up = (DIM[3] * 2 - tb.ball['position'].y - card.pos.y) // t0
            vel_down = (tb.ball['position'].y + card.pos.y) // t0
            vel_possible = [vel_up - 1, vel_up, vel_up + 1, vel_down - 1, vel_down, vel_down + 1]
            for vel in vel_possible:
                new_action = RacketAction(tb.tick, bat, vel - tb.ball['velocity'].y, None, None, None)
                if tb.op_side['active_card'][1] == 'SP':
                    new_action.acc = int(new_action.acc / CARD_SPIN_PARAM)
                new_route = Route(tb.ball['position'].y, vel, new_action, 'HIT_CARDS')
                if new_route.isLegal() and card in new_route.getCards():
                    routes.append(new_route)

    class Rally:
        def __init__(self):
            self.mode = []

        def run_method(self, menu, history):
            pass
            run = (DIM[3] - DIM[2]) // 2 - tb.ball['position'].y
            return run

    def get_run_strategy(route):
        rally = Rally()
        rally.mode.append(route.mode)
        if abs(route.end - tb.op_side['position'].y) >= (DIM[3] // 2):
            rally.mode.append('FAR_SIDE')
        else:
            rally.mode.append('NEAR_SIDE')
        run_menu = {}
        route.action.run = rally.run_method(run_menu, ds)

    def get_card_strategy(route):
        for card in tb.side['cards']:
            if card.code == 'IL' or card.code == 'DL' or card.code == 'SP' or card.code == 'DS':
                route.action.card = (None, card)
                break
            elif card.code == 'TP':
                if route.action.run ** 2 // FACTOR_DISTANCE ** 2 >= 300 or len(tb.side['cards']) >= 3:
                    route.action.card = (None, card)
                    break
            elif card.code == 'AM':
                if abs(route.end - tb.op_side['position'].y) ** 2 // FACTOR_DISTANCE ** 2 > 300 or len(tb.side['cards']) >= 3:
                    route.action.card = (None, card)
                    break


    # evaluate之前更新acc！
    def evaluate(route):
        cost = 0
        # 加速花费
        acc_cost = route.action.acc ** 2 // FACTOR_SPEED ** 2
        cost += acc_cost
        if tb.op_side['active_card'][1] == 'SP':
            route.action.acc *= CARD_SPIN_PARAM
        # 跑位花费
        run_cost = route.action.run ** 2 // FACTOR_DISTANCE ** 2
        cost += run_cost
        # 对方击球花费（最小消耗模式）
        aim_pos = route.end
        if tb.op_side['run_vector'] is None or (aim_pos - tb.op_side['position'].y) * tb.op_side['run_vector'] > 0:
            op_run_cost = (aim_pos - tb.op_side['position'].y) ** 2 // FACTOR_DISTANCE ** 2 / 4
            op_bat_cost = (aim_pos - tb.op_side['position'].y) ** 2 // FACTOR_DISTANCE ** 2 / 4
        else:
            op_run_cost = 0
            op_bat_cost = (aim_pos - tb.op_side['position'].y) ** 2 // FACTOR_DISTANCE ** 2
        cost -= int(op_run_cost + op_bat_cost)
        # # 对方加速花费
        # # 先只管安全速度
        # op_sec = secureVelocity(target_pos)
        # op_vel = predictvel_op(pos, vel + acc)
        # op_acc_cost = 0
        # if not issecure(target_pos, op_vel):
        #     if op_vel >= op_sec[0]:
        #         op_acc_cost = ((op_vel - op_sec[0]) / FACTOR_SPEED) ** 2
        #     if op_vel <= op_sec[3]:
        #         op_acc_cost = ((op_vel - op_sec[3]) / FACTOR_SPEED) ** 2
        #     if op_vel <= op_sec[1] and op_vel > 0:
        #         op_acc_cost = ((op_vel - op_sec[1]) / FACTOR_SPEED) ** 2
        #     if op_vel >= op_sec[2] and op_vel < 0:
        #         op_acc_cost = ((op_vel - op_sec[2]) / FACTOR_SPEED) ** 2
        # cost -= op_acc_cost

        # 我方下次击球花费
        # 先按对方不改变速度估计好了，这个一定要学习....
        # cost += ((predictpos_back(pos, vel + acc) - pos - run) / FACTOR_DISTANCE) ** 2

        for card in route.getCards():
            cost -= card_value[card.code]

        if route.action.card[1] is not None:
            card_used = route.action.card[1].code
        else:
            card_used = ''
        if card_used == 'SP':
            pass
            #cost -= op_acc_cost * 3
        elif card_used == 'IL':
            cost -= 2000
        elif card_used == 'DL':
            cost -= 2000
        elif card_used == 'TP':
            cost -= run_cost
            new_run_cost = max(route.action.run - CARD_TLPT_PARAM, 0) ** 2 // FACTOR_DISTANCE ** 2
            cost += new_run_cost
        elif card_used == 'AM':
            cost -= op_bat_cost
            #cost -= op_acc_cost
        if tb.op_side['active_card'][1] == 'SP':
            route.action.acc = int(route.action.acc / CARD_SPIN_PARAM)

        return cost

    hit_corners()
    hit_cards()
    index = sys.maxsize
    route_chosen = None
    for route in routes:
        get_run_strategy(route)
        get_card_strategy(route)
        delta = evaluate(route)
        if delta < index:
            route_chosen = route
            index = delta

    return route_chosen.action


def summarize(tick: int, winner: str, reason: str, west: RacketData, east: RacketData, ball: BallData, ds: dict):
    return
