# to do: 1. 优化道具价值 2. 保存对方上次位置 3. 优化对方击球花费（传送卡） 4. 优化对方加速花费 5. 优化我方击球花费（加倍卡） 6. 考虑道具容量
# 7. 改进搜索算法 8. 改进发球算法 9. 考虑如何搜索是否使用道具
from table import *
# 参数设定
tick_step = (DIM[1] - DIM[0]) // BALL_V[0]
serve_para = 'upmax'
card_strategy = 'evaluation'
card_value = {'SP':400,'DS':10,'IL':4000,'DL':4010,'TP':2000,'AM':4000}
# 安全速度计算
def secureVelocity(pos):
    up_ub = (DIM[3]*3-pos)//tick_step
    up_lb = (DIM[3]-pos)//tick_step
    down_lb = - (DIM[3] * 2 + pos) // tick_step
    down_ub = - pos//tick_step
    return [up_ub,up_lb,down_ub,down_lb]

# 判断速度是否安全
def issecure(pos,vel):
    sec=secureVelocity(pos)
    if vel>=sec[0] or vel<=sec[3]:
        return False
    if vel<=sec[1] and vel>=sec[2]:
        return False
    return True

# 预测落点
def predictpos_op(pos,vel):
    if not issecure(pos,vel):
        return -1
    return (pos+vel*tick_step)%DIM[3]

# 预测击回时落点
def predictpos_back(pos,vel):
    op_pos=predictpos_op(pos,vel)
    vel=-vel
    if issecure(op_pos,vel):
        return predictpos_op(pos,vel)
    sec=secureVelocity(op_pos)
    if vel>=sec[0]:
        return DIM[3]
    if vel<=sec[3]:
        return 0
    if vel <= sec[1] and vel > 0:
        return DIM[3]
    return 0

# 发球函数，总是做为West才发球
# ds为函数可以利用的存储字典
# 函数需要返回球的y坐标，和y方向的速度
def serve(ds:dict) -> tuple:
    # 发球模式：向上最大
    if serve_para=='upmax':
        sec=secureVelocity(0)
        return 0, sec[0]-1
    return BALL_POS[1], BALL_V[1]

# 打球函数
# tb为TableData类型的对象
# ds为函数可以利用的存储字典
# 函数需要返回一个RacketAction对象
def play(tb:TableData, ds:dict) -> RacketAction:
    # 参数
    vbond = secureVelocity(tb.ball['position'].y)
    vel0 = - tb.ball['velocity'][1]
    pos0=tb.ball['position'].y
    op_card=tb.op_side['activate_card']
    cards=tb.side['cards']
    tb_cards=tb.cards['cards']
    # 回头改成历史数据
    op_pos=tb.op_side['position']
    op_run=tb.op_side['run_vector']
    # 核心函数1：赋值函数
    # 暂时不考虑体力限制先.......
    def evaluation(pos,vel,tb_cards,op_pos,op_run,op_card,cards,acc,run,use_card):
        cost=0
        # 加速花费
        cost+=(acc/FACTOR_SPEED)^2
        if op_card[1] ==CARD_SPIN:
            acc=acc*CARD_SPIN_PARAM
        # 跑位花费
        run_cost=(run/FACTOR_DISTANCE)^2
        cost+=run_cost
        # 对方击球花费
        # 先用对方最小消耗吧
        target_pos=predictpos_op(pos,vel+acc)
        if op_run is None or (target_pos-op_pos)*op_run>0:
            op_run_cost= ((target_pos-op_pos)/FACTOR_DISTANCE)^2/4
            op_hit_cost=((target_pos-op_pos)/FACTOR_DISTANCE)^2/4
        else:
            op_run_cost=0
            op_hit_cost= ((target_pos-op_pos)/FACTOR_DISTANCE)^2
        cost=cost-op_run_cost-op_hit_cost
        # 对方加速花费
        # 先只管安全速度
        op_sec=secureVelocity(target_pos)
        op_vel=-(vel+acc)
        if not issecure(target_pos,op_vel):
            if op_vel >= op_sec[0]:
                op_acc_cost=((op_vel-op_sec[0])/FACTOR_SPEED)^2
            if op_vel <= op_sec[3]:
                op_acc_cost= ((op_vel - op_sec[3]) / FACTOR_SPEED) ^ 2
            if op_vel<=op_sec[1] and op_vel>0:
                op_acc_cost= ((op_vel - op_sec[1]) / FACTOR_SPEED) ^ 2
            if op_vel>=op_sec[2] and op_vel<0:
                op_acc_cost= ((op_vel - op_sec[2]) / FACTOR_SPEED) ^ 2
        cost-=op_acc_cost
        # 我方下次击球花费
        # 先按对方不改变速度估计好了，这个一定要学习....
        cost+=((predictpos_back(pos,vel+acc)-pos-run)/FACTOR_DISTANCE)^2
        # 捡道具花费，假装不会捡满先.......
        action = RacketAction(tb.tick, tb.ball['position'].y - tb.side['position'].y, acc, 0, None, None)
        c_bounce, hit_cards,ball=testrun(action)
        for card in hit_cards:
            cost-=card_value[card.code]
        # 使用道具花费
        card_savevalue = {'SP': 200, 'DS': -10, 'IL': 1970, 'DL': 1960, 'TP': 980, 'AM': 1000}
        cost+=card_savevalue[use_card]
        if use_card=='SP':
            cost-=op_acc_cost*3
        if use_card=='IL' or use_card=='DL':
            cost-=2000
        if use_card=='TP':
            cost-=run_cost
            cost+=(max(run-CARD_TLPT_PARAM,0)/FACTOR_DISTANCE)^2
        if use_card=='AM':
            cost-=op_hit_cost
        return cost
    # 核心函数2：寻找最优解函数

    # 暴力搜索加速度先
    accmin=0
    costmin=100000
    for acc in range(vbond[1]-vel0,vbond[0]-vel0):
        if evaluation(pos0,vel0,tb_cards,op_pos,op_run,op_card,cards,acc,0,None)<costmin:
            accmin=acc
            costmin=evaluation(pos0,vel0,tb_cards,op_pos,op_run,op_card,cards,acc,0,None)
    for acc in range(vbond[4]-vel0,vbond[3]-vel0):
        if evaluation(pos0,vel0,tb_cards,op_pos,op_run,op_card,cards,acc,0,None)<costmin:
            accmin=acc
            costmin=evaluation(pos0,vel0,tb_cards,op_pos,op_run,op_card,cards,acc,0,None)

    # 暴力搜索跑位
    runmin=0
    for run in range(-pos0,DIM[3]-pos0):
        if evaluation(pos0,vel0,tb_cards,op_pos,op_run,op_card,cards,accmin,run,None)<costmin:
            runmin=run
            costmin=evaluation(pos0,vel0,tb_cards,op_pos,op_run,op_card,cards,accmin,run,None)

    # 是否使用道具
    # 未实现


    action = RacketAction(tb.tick, tb.ball['position'].y - tb.side['position'].y, accmin, runmin, None, None)
    # 测试运行结果
    def testrun(action):
        ball = Ball(DIM, tb.ball['position'], tb.ball['velocity'])
        ball.update_velocity(action.acc, tb.op_side['activate_card'])
        ball.bounce_racket()
        count_bounce, hit_cards = ball.fly(tick_step, tb.cards['cards'])
        return count_bounce, hit_cards, ball
    return action

# 对局后保存历史数据函数
# ds为函数可以利用的存储字典
# 本函数在对局结束后调用，用于双方分析和保存历史数据
def summarize(tick:int, winner:str, reason:str, west:RacketData, east:RacketData, ball:BallData, ds:dict):
    return
