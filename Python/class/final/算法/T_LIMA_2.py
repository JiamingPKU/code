from table import RacketAction

a = 900000
b = 1000000
v0 = 1800

def daoju(p,x,y,v):
	a = 900000
	b = 1000000
	vy=[]
	w=[]
	if x+a<=2*a*(p-y)//(2*b+p) or x+a<=2*a*(y-p)//(3*b-p):
		return None,None
	else:
		if x+a<=2*a*(p-y)//p:
			vy+=[(y-p)*v0//x]
			w+=[(vy-v)**2//400]
		else:
			vy+=[None]
			w+=[None]
		if x+a<=2*a*(y-p)//(b-p):
			vy+=[(y-p)*v0//x]
			w+=[(vy-v)**2//400]
		else:
			vy+=[None]
			w+=[None]
		if x+a>=2*a*(y+p)//(2*b+p):
			vy+=[(-y-p)*v0//x]
			w+=[(vy-v)**2//400]
		else:
			vy+=[None]
			w+=[None]
		if x+a>=2*a*(y-b+p)//(p-3*b):
			vy+=[(2*b-y-p)*v0//x]
			w+=[(vy-v)**2//400]
		else:
			vy+=[None]
			w+=[None]
		if x+a>=2*a*y//(2*b+p+2*a):
			vy+=[(y-p-2*b)*v0//x]
			w+=[(vy-v)**2//400]
		else:
			vy+=[None]
			w+=[None]
		if x+a>=2*a*(y-b)//(3*b-p)+2*a:
			vy+=[(2*b+y-p)*v0//x]
			w+=[(vy-v)**2//400]
		else:
			vy+=[None]
			w+=[None]
	return 1

def jieqiu(y,ye,v):
	if y!=0 and y!=1000000:
		yi = y+v*1800
		t=1801
		listyt=[3e6-t,2e6+t,2e6,2e6-t,1e6+t,1e6,0,-t,-1e6+t,-1e6,-1e6-t,-2e6+t]
		listyreal=[1e6-t,t,0,t,1e6-t,1e6,0,t,1e6-t,1e6,1e6-t,t]
		i=1
		vy=(listyt[0]-y)/1800
		delta=(listyreal[0]-(5e5+ye))**2/(4e8)-(listyt[0]-yi)**2/((1800**2)*(20**2))
		while i<=11:
			if i!=1 and i!=2 and i!=9 and i!=10:
				deltat=(listyreal[i]-(5e5+ye))**2/(4e8)-(listyt[i]-yi)**2/((1800**2)*(20**2))
				if deltat>delta:
					delta=deltat
					vy=(listyt[i]-y)/1800
			i+=1

	elif y==0:
		v1=0
		ye0=ye+5e5
		v10=45/28*1000-9/11200*ye0+v/2.24
		v20=45/28*1000+9/11200*ye0+v/2.24
		if v10<=5000/9:
			v1=10000/9
		elif v10>5000/9 and v10<10000/9:
			if v10-5000/9>10000/9-v10:
				v1=5000/9
			else:
				v1=10000/9
		else:
			v1=5000/9
		v2=0
		if v20<10000/9:
			v2=15000/9
		elif v20>10000/9 and v20<15000:
			if v20-10000/9>15000/9-v2:
				v2=10000/9
			else:
				v2=15000/9
		else:
			v2=10000/9
		if v1>v2:
			vy=v1
		else:
			vy=v2
	elif y==1e6:
		v1=0
		ye0=1e6-(ye+5e5)
		v10=45/28*1000-9/11200*ye0-v/2.24
		v20=45/28*1000+9/11200*ye0-v/2.24
		if v10<=5000/9:
			v1=10000/9
		elif v10>5000/9 and v10<10000/9:
			if v10-5000/9>10000/9-v10:
				v1=5000/9
			else:
				v1=10000/9
		else:
			v1=5000/9
		v2=0
		if v20<10000/9:
			v2=15000/9
		elif v20>10000/9 and v20<15000:
			if v20-10000/9>15000/9-v2:
				v2=10000/9
			else:
				v2=15000/9
		else:
			v2=10000/9
		if v1>v2:
			vy=-v1
		else:
			vy=-v2
	return vy
			


	

def serve(op_side,ds):
	return 500000,833#中位发球，碰2次发到角

def play(tb,ds):#tb是tabledata类型，ds是datastore类型
	#x:迎球阶段距离差
	x = tb.ball['position'].y-tb.side['position'].y
	#xx:迎球阶段最短移动距离
	xx = 0 if abs(x)<2000 else x-2000*x//abs(x)
	#y:无墙时碰到的位置
	y = tb.ball['position'].y+tb.ball['velocity'].y*1800
	#y1:y下面第一个边界(包括y)
	y1 = 1000000*(y//1000000)
	#y2:y上面第一个边界(不包括y)
	y2 = y1+1000000
	'''
	if y>3000000:
		v=(3000000-tb.ball['position'].y)//1800-1
	elif y<-2000000:
		v=(-2000000-tb.ball['position'].y)//1800+1
	elif y>0 and y<1000000:
		v = (1000000-tb.ball['position'].y)//1800+1#要修改
	elif tb.op_side['run_vector'] and (500000-tb.op_side['position'].y)//tb.op_side['run_vector']>0 or not tb.op_side['run_vector']:
		v = (y1-tb.ball['position'].y)//1800+1 if y-y1<y2-y else (y2-tb.ball['position'].y)//1800-1
	else:
		v = (y1-tb.ball['position'].y)//1800+1 if tb.op_side['run_vector']==1 else (y2-tb.ball['position'].y)//1800-1
	'''
	
	return RacketAction(None, xx, jieqiu(tb.ball['position'].y,0,tb.ball['velocity'].y)-tb.ball['velocity'].y, 500000-tb.side['position'].y-xx, None, None)

def summarize(tick, winner, reason, west, east, ball, ds):
	return