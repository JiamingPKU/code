## 阅读题目

### 过程

#### 输入

+ td 桌面态势
+ ds 历史数据

#### 输出

+ 迎球
+ 触球
+ 跑位


#### 关于三个过程的思考

+ 能量如何计算？和球拍的运动速度是否相关？（如果不相关，那么球拍在迎球时运动一步到位）
+ 触球要考虑到球目前的速度、自己消耗的能量、击球时对方球拍的位置、对方改变球拍的能量
+ 跑位要考虑对方决策：即对方触球时为了使自己最优要做出的决策

### 其他问题

#### 历史数据的作用和利用

+ 依据历史数据推算出对方触球的函数？
+ 依据历史数据来预测对方的
  + 触球~调整自己的跑位，影响对方触球（对方触球行为也会随之发生改变）
  + 跑位~调整自己的触球

#### 是否存在无条件最优？

+ 如果存在，那么我们只要找到这个函数即可
+ 如果不存在，那么我们需要找到有条件的最优

#### 在存在条件最优的前提下

+ （显然是存在的），那么我们如果识别条件？（发现对方的击球行为）
+ 识别条件后如何做出反应
+ 如何把我们自身作为一个困难的条件（使得对方的最优函数结果最差）
  + 对方的最优函数是否可知？




## 阅读代码：

### pingpong.py

乒乓对战主程序，自动查找当前目录下“T_*.py”的文件作为算法，两两对战，并输出结果（文本）和复盘数据（以shelve模块方式保存）

### T_idiot.py

示例对战算法，只被动接球。

### table.py

主要类Table、LogEntry等定义。定义桌面的主要变量。

#### 1.参数

DIM, TMAX, BALL_POS, BALL_V, RACKET_LIFE, …

#### 2.位置 (*Position*)

*Position*是*Vector*的子类

#### 3.球 (*Ball*)

+ *Ball*的参数：
  + 坐标系参数*extent*，
  + 球的位置坐标*pos*，
  + 球的运动速度矢量*velocity*
+ *Ball*的函数：
  + bounce_ball
  + bounce_racket
  + update_velocity
  + fly

#### 4.球拍动作 (*RacketAction*)

+ *RacketAction*的参数
  + *bat* 迎球
  + *acc* 触球
  + *run* 跑位

#### 5.球拍 (*Racket*)

+ *Racket*的参数
  + side, pos
  + life
  + name, play, action, datastore
+ *Racket* 的函数
  + bind_play
  + set_action
  + set_datastore
  + update_pos_bat
  + update_acc

#### 6. 球桌信息 (*TableData*)

+ *TableData*的参数
  + tick
  + step
  + side
  + op_side
  + ball

#### 7.球拍信息 (*RacketData*)

+ *RacketData*的参数
  + side, name, life, …

#### 8.球的信息 (*BallData*)

+ *BallData*的参数

#### 9.球桌 (*Table*)

+ *Table*的参数
+ *Table*的函数

#### 10.登陆 (*LogEntry*)