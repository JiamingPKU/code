# Function Lists of YsZhu





### 安全速度 secureVelocity

```python
def secureVelocity(pos):
    #pos: y值
    return [up_ub.__int__(), up_lb.__int__(), down_ub.__int__(), down_lb.__int__()]
```

### 判断速度是否安全 

```python
def issecure(pos, vel):
    #vel: v.vy
	return True/False
```

### 预测落点

```python
def predictpos_op(pos, vel):
	return pos_op
```

### 预测对方速度

```python
def predictvel_op(pos, vel):
    return op_vel
```

### 预测击回时落点

```python
def predictpos_back(pos, vel)->pos.vy:
	return 0/DIM[3]/pos_back
```

### 发球函数

```python
def serve(op_side: str, ds: dict) -> tuple:
    return BALL_POS[1], BALL_V[1]
```

### 初始化函数

```python
def initialize(ds: dict):
    ds['op_pos'] = (DIM[3] - DIM[2]) // 2
    ds['op_prevpos'] = (DIM[3] - DIM[2]) // 2
    ds['op_prevlife'] = RACKET_LIFE
```

### 打球函数

#### 传入参数

```python
    # 参数 part1
    tick_step = tb.step
    turns = tb.tick // (2 * tb.step) + 1
    firstturn = False
    if turns == 1:
        initialize(ds)
        firstturn = True
    # 参数 part2
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
```

#### 测试运行结果

```python
# 测试运行结果
def testrun(action, cards):
        ball1 = Ball(DIM, Vector(ball_pos[0], ball_pos[1]), Vector(ball_vel[0], ball_vel[1]))
        # 旋转球不在这里实现
        ball1.update_velocity(action.acc, [None, None])
        ball1.bounce_racket()
        count_bounce, hit_cards = ball1.fly(tick_step, list(cards))
        return count_bounce, hit_cards, ball1
```

#### 核心函数1：赋值函数

```python
def evaluation(pos, vel, life, op_life, tb_cards, op_pos, op_run, op_card, cards, acc, run, use_card):
```

#### 斩杀函数

```python
# 斩杀函数
op_max_distance = op_life / RACKET_LIFE * BALL_V[1] * tick_step
if op_max_distance < DIM[3]:
if op_run is None or (target_pos - op_pos) * op_run > 0:
if (target_pos - op_pos) > 2 * op_max_distance:
	cost -= sys.maxsize
else:
	if (target_pos - op_pos) > op_max_distance:
```

#### 核心函数2：寻找最优解函数

```python
# 使用道具
deck = tb.side['cards']
emptycard = Card('', None, None)
deck.append(emptycard)
costmin = sys.maxsize
run = (DIM[3] - DIM[2]) // 2 - pos0
```

```python
def searchaccrange(start, stop, step, paras):
    p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 = paras
    if stop - start < 25:
        accs = list(range(start, stop + 1))
        costs = [evaluation(p1, p2, p3, p4, p5, p6, p7, p8, p9, accforsearch, p10, p11) for accforsearch in accs]
        mincost = min(costs)
        minaccindex = costs.index(mincost)
        return accs[minaccindex], mincost
    accs = list(range(start, stop, step))
    accs.append(stop)
    costs = [(evaluation(p1, p2, p3, p4, p5, p6, p7, p8, p9, accforsearch, p10, p11)) for accforsearch in accs]
    costssorted = copy.copy(costs)
    costssorted.sort()
    mincosts = [costssorted[0], costssorted[1]]
    minaccindex = [costs.index(mincosts[0]), costs.index(mincosts[1])]
    if minaccindex[0] == minaccindex[1]:
        minaccindex[1]=costs.index(mincosts[1], costs.index(mincosts[0]) + 1)
    minaccindex.sort()
    minacc = [accs[minaccindex[0]], accs[minaccindex[1]]]
    if minacc[1] - minacc[0] != step:
        a1,costa1 = searchaccrange(minacc[0]-step,minacc[0]+step,step//5,paras)
        a2,costa2 = searchaccrange(minacc[1]-step,minacc[1]+step,step//5,paras)
        if costa1 < costa2:
            return a1, costa1
        else:
            return a2, costa2
    return searchaccrange(minacc[0], minacc[1], (minacc[1] - minacc[0]) // 10, paras)
```

