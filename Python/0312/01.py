#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Jack
# @Date:   2017-03-12 15:00:54
# @Last Modified by:   Jack
# @Last Modified time: 2017-03-12 16:14:36


import pandas as pd
import numpy as np
import matplotlib.pylab as plt
# %matplotlib inline
from matplotlib.pylab import rcParams
rcParams['figure.figsize']=15,6

# import the data
data = pd.read_csv("AirPassengers.csv")
print(data.head())
print("\n Data Types:")
print(data.dtypes)


dateparse = lambda dates: pd.datetime.strptime(dates, '%Y-%m')
data = pd.read_csv("AirPassengers.csv",parse_dates="Month", index_col="Month", date_parser=dateparse)
print(data.head())