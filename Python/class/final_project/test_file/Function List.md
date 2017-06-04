# Function List

### Part 1. 系统函数

###### serve

###### play

###### summarize

### Part 2. 基本函数

###### get_safe_v：获得安全速度

```python
def get_safe_v(pos, v, dim) -> tuple:
    # pos:球的位置
    # v:球速
    # dim: 桌面大小
    return max_v, min_v
```

###### get_ball:根据每一个发球位置和球速计算球的落点状态

```python
def get_ball(pos, v: Vector, dim) -> tuple:
    # pos： 触球位置
    # v: 球速
    # dim: 桌面
    
    # 结果是一个tuple, 元素分别为一个Vector和一个落点纵坐标
    return v, get_pos_y
```

###### get_v:计算必要的球速函数

```python
def get_v(pos, op_pos, v, dim):
    # pos：己方击球点
    # op_pos: 对方球的落点
    # v: 触球时的球速,实际上只与vx有关
    # dim: 桌面坐标
    # 得到可能的球速取值（4个值）
    return y_distance / t
```

###### cost_run:移动消耗

```python
def cost_run(distance, FD=FACTOR_DISTANCE):
    # distance: 移动距离
    return abs(distance) ** 2 // FD ** 2
```

###### cost_acc:改变球速的消耗

```python
def cost_acc(acc, FS=FACTOR_SPEED):
    # acc:改变球速大小
    return abs(acc) ** 2 // FS ** 2
```

###### cost_acc_pos：为了将球击到特定位置的消耗(改变速度的消耗)

```python
def cost_acc_pos(pos, op_pos, v: Vector, dim) -> tuple:
    # pos：自己触球时的位置
    # op_pos： 对方触球时的位置
    # v:自己触球时的球速
    # dim：桌面坐标
    
    return acc_list, cost_acc_list
    # 得到一个tuple,第一个元素为加速方式的选择，第二个元素为对应的消耗
```

###### cost:一次产生的消耗

```python
def cost(pos, pos_last, run, acc, FD=FACTOR_DISTANCE, FS=FACTOR_SPEED):
    # pos:触球时的位置
    # pos_last:上一次触球时的位置
    # run:跑位距离
    # acc:触球改变球速大小
    return cost_total
```



### Part3. 策略函数

###### count_run:跑位策略

```python
# 跑位策略：跑位到预期落点的一半距离
def count_run(pos, next_pos):
    # pos: 当前球拍位置
    # next_pos:下一期的触球位置（预期）

    return run_vector
```

###### count_acc1:触球策略1

```python
# 触球策略1：最大化一次击球收益
def count_acc1():
    pass
```

###### count_acc2:触球策略2

```python
# 触球策略2：固定打角
def count_acc2(pos, v: Vector, allPublicInfo, dim, ds):
    # pos： 触球时的位置
    # v： 触球时球的速度
    # allPublicInfo：历史共同信息
    # dim: 桌面坐标
    return acc2
```

###### count_bat:迎球策略

```python
def count_bat(pos, op_pos, op_v):
    # pos: 迎球开始时自己的位置
    # op_pos: 对方发球时的位置
    # op_v：对方发球时球的速度
    return bat_vector
```

### Part4. 预测函数

###### class publicInfo 一期公共信息

```python
class publicInfo:

    def __init__(self, pos, run, op_pos, op_run, v: Vector, op_v: Vector):
        self.pos = pos  # 自己的触球位置
        self.run = run  # 自己的跑位方向
        self.op_pos = op_pos  # 对方的触球位置
        self.op_run = op_run  # 对方的跑位方向
        self.v = v  # 自己触球后球速
        self.op_v = op_v  # 对方触球后球速
        
    def getNew(self, pos, run, op_pos, op_run, v: Vector, op_v: Vector):
        pass
```

###### class allPublicInfo 所有期的公共信息

```python
class allPublicInfo(list):
```

###### get_op_run:预测对方跑位

```python
def get_op_run(pos_last, run_last, op_pos_last, op_v_last: Vector, dim, ds):
    # pos_last: 对方触球时观测到我方的位置（应该是上一次的我方触球位置）
    # run_last：对方触球时观测到我方的跑位情况（应该是上一次的我方跑位情况）
    # op_pos_last: 对方上一次触球位置
    # op_v_last: 对方上一次触球后的球速（可以预期球的我方落点）
    # dim:桌面大小
    # ds：其他历史信息

    return run
```

###### get_op_acc:预测对方触球

```python
def get_op_acc(op_v: Vector, op_pos, pos_last, run_last, dim, ds):
    # op_v:对方触球前的球速
    # op_pos：对方触球时的球的位置
    # pos_last: 我方上一次的位置
    # run_last：我方上一次的跑位

    return op_acc
```

###### predict_run:预测对方跑位

###### predict_acc:预测对方触球变速

### 传入参数

```
tick_step = tb.step
turns = tb.tick // (2 * tb.step) + 1
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

deck = tb.side['cards']


ds['op_prevrun'] = 0
ds['op_prevacc'] = vel0 + ds['prevvel']
ds['op_prevlife'] = op_life
ds['op_pos'] = op_nextpos
ds['op_prevpos'] = op_pos
ds['prevvel'] = vel0 + accmin
```