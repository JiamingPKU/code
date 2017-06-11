from table import *
import sys
import copy
import random

# 参数
LIFE_LIMIT = 50000
tick_step = (DIM[1] - DIM[0]) // BALL_V[0]
# unit = (DIM[3] - DIM[2]) // 4
# spots = [unit * i for i in range(1, 3)]
card_value = {'SP': 2000, 'DS': 10, 'IL': 4000, 'DL': 4010, 'TP': 400, 'AM': 2000}
run_menu = {}
memory = {}


def sign(value):
    if value > 0:
        return 1
    elif value < 0:
        return -1
    else:
        return 0


def swap(alist):
    alist[0], alist[1] = alist[1], alist[0]


# 临界速度计算
def vel_critical(pos):
    up_ub = int((DIM[3] * 3 - pos) / tick_step) - 1                  # bounces = 2
    up_mid = int((DIM[3] * 2 - pos) / tick_step) + 1                 # bounces = 2
    up_lb = int((DIM[3] - pos) / tick_step) + 1                      # bounces = 1
    down_lb = -int((DIM[3] * 2 + pos) / tick_step) + 1               # bounces = 2
    down_mid = -int((DIM[3] + pos) / tick_step) - 1                  # bounces = 2
    down_ub = -int(pos / tick_step) - 1                              # bounces = 1
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

# def serve(op_side: str, ds: dict) -> tuple:
#     return BALL_POS[1], random.randrange(500, BALL_V[1])

def initialize_memory(memo):
    memo['rallies'] = []


def serve(op_side: str, ds: dict) -> tuple:
    # 发球模式：向上最大
    initialize_memory(memory)
    return 0, vel_critical(0)[0][0]


def play(tb: TableData, ds: dict) -> RacketAction:
    # 参数
    bat = tb.ball['position'].y - tb.side['position'].y
    routes = []
    turns = tb.tick // (2 * tb.step) + 1
    if turns == 1:
        initialize_memory(memory)

    def initialize_run_menu():
        run_menu['HIT_UPWARDS'] = [(DIM[3] - tb.ball['position'].y) // 2 - tb.ball['position'].y,
                                          DIM[3] // 2 - tb.ball['position'].y]
        run_menu['HIT_DOWNWARDS'] = [(tb.ball['position'].y // 2) - tb.ball['position'].y,
                                            DIM[3] // 2 - tb.ball['position'].y]
        run_menu['HIT_CARDS'] = [(DIM[3] - tb.ball['position'].y) // 2 - tb.ball['position'].y,
                                        (tb.ball['position'].y // 2) - tb.ball['position'].y]

    initialize_run_menu()

    def update_run_menu(traits):
        swap(run_menu[traits])

    def match(traits, test_route):
        if traits == 'HIT_UPWARDS' or traits == 'HIT_DOWNWARDS':
            return run_menu[traits][0]
        elif traits == 'HIT_CARDS':
            if test_route.vel0 >= 0:
                return run_menu[traits][0]
            else:
                return run_menu[traits][1]

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
            self.bounces, self.cards = test(self.action)

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
                if new_route.getEnd() > (DIM[3] // 2):
                    new_route.mode = 'HIT_UPWARDS'
                else:
                    new_route.mode = 'HIT_DOWNWARDS'
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

    class RunMode:
        def __init__(self):
            self.traits = ''
            self.approach = None

        def add_traits(self, new_traits):
            # if isinstance(new_traits, list):
            #     for trait in new_traits:
            #         self.traits.add(trait)
            # else:
            #     self.traits.add(new_traits)
            self.traits = new_traits

        def resembles(self, other):
            return self.traits == other.traits

    class Rally:
        def __init__(self, route):
            self.mode = RunMode()
            self.route = route
            self.mode.add_traits(self.route.mode)
            self.side_info = {}
            self.op_side_info = {}
            self.outcome = None

        # def extract_mode(self):
        #     self.mode.add_traits(self.route.mode)
        #     # if abs(self.route.end - tb.op_side['position'].y) >= (DIM[3] // 2):
        #     #     self.mode.add_traits('FAR_SIDE')
        #     # else:
        #     #     self.mode.add_traits('NEAR_SIDE')
        #
        # self.extract_mode()

        def update_info(self, tb_current, param):
            if param == 'INITIAL':
                self.side_info['life_initial'] = tb_current.side['life']
                self.op_side_info['life_initial'] = tb_current.op_side['life']
                self.op_side_info['card_used'] = tb_current.op_side['active_card']
            elif param == 'FINAL':
                self.side_info['life_final'] = tb_current.side['life']
                self.op_side_info['life_final'] = tb_current.op_side['life']
                self.outcome = (self.op_side_info['life_final'] - self.op_side_info['life_initial'])\
                               - (self.side_info['life_final'] - self.side_info['life_initial'])

    def danger(life):
        max_distance = life / RACKET_LIFE * (DIM[1] - DIM[0])
        if max_distance < DIM[3] * 3 / 4:
            return True
        else:
            return False

    # 如果体力值足够
    if not danger(tb.side['life']):
        quarters = range(DIM[2], DIM[3], (DIM[3] - DIM[2]) // 4)
        quarters = quarters[1:]
        runs = [p - tb.ball['position'].y for p in quarters]
        runabs = [abs(p) for p in runs]
        minrunabs = min(runabs)
        minrunindex = runabs.index(minrunabs)
        run = runs[minrunindex]
    # 如果体力值不够跑到3/4的位置
    else:
        run = (DIM[3] - DIM[2]) // 2 - tb.ball['position'].y

    def get_run_strategy(route, history):
        test_rally = Rally(route)
        index = 0
        count = 0
        for pre_rally in history['rallies']:
            if test_rally.mode.resembles(pre_rally.mode):
                count += 1
                index += sign(pre_rally.outcome) * count // 2
        if index >= 0:
            run = match(test_rally.mode.traits, route)
        else:
            update_run_menu(test_rally.mode.traits)
            run = match(test_rally.mode.traits, route)

        # if tb.side['life'] < 50000:
        #     run = DIM[3] // 2 - route.start
        # elif route.start < DIM[3] // 4:
        #     run = (DIM[3] - route.start) // 2 - route.start
        # elif route.start > 3 * DIM[3] // 4:
        #     run = route.start // 2 - route.start
        # else:
        #     run = DIM[3] // 2 - route.start

        # if tb.side['life'] < LIFE_LIMIT:
        #     run = DIM[3] // 2 - route.start
        # elif route.start > 3 * DIM[3] // 4:
        #     run = 3 * DIM[3] // 4 - route.start
        # elif route.start < DIM[3] // 4:
        #     run = DIM[3] // 4 - route.start
        # else:
        #     run = DIM[3] // 2 - route.start

        route.action.run = run

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
        aim_pos = route.getEnd()
        # if aim_pos is None:
        #     aim_pos = 0
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

    def update_memory():
        if len(memory['rallies']) >= 1:
            pre_rally = memory['rallies'][-1]
            pre_rally.update_info(tb, 'FINAL')

    def memorize(route):
        new_rally = Rally(route)
        new_rally.update_info(tb, 'INITIAL')
        memory['rallies'].append(new_rally)

    update_memory()
    hit_corners()
    hit_cards()
    index = sys.maxsize
    route_chosen = None
    for route in routes:
        # get_run_strategy(route, memory)
        route.action.run = run

        get_card_strategy(route)
        delta = evaluate(route)
        if delta < index:
            route_chosen = route
            index = delta

    memorize(route_chosen)

    return route_chosen.action


def summarize(tick: int, winner: str, reason: str, west: RacketData, east: RacketData, ball: BallData, ds: dict):
    return
