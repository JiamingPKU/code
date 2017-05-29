# -*- coding: utf-8 -*-
"""
Created on Wed May 24 01:37:18 2017

@author: Ren Qingjie
"""
from table import *


def serve(ds:dict) -> tuple:
    return BALL_POS[1], BALL_V[1]






def play(tb:TableData, ds:dict) -> RacketAction:
    return RacketAction(tb.tick, tb.ball['position'].y - tb.side['position'].y, 0, 0, None, None)


def summarize(tick:int, winner:str, reason:str, west:RacketData, east:RacketData, ball:BallData, ds:dict):
    return

