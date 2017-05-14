# -*- coding: utf-8 -*-
# @Author: Ren Qingjie
# @Date:   2017-05-14 15:48:55
# @Last Modified by:   Ren Qingjie
# @Last Modified time: 2017-05-14 16:22:35


import time
import os
import sys
import signal
import sakshat
import picamera
import face_recognition
from PIL import Image


s = sakshat.SAKSHAT()
c = picamera.PiCamera()

# 总体名单及对应的编号
leaders = {0: 'DengXiaoping', 1: 'HuaGuofeng', 2: 'HuJintao', 3: 'HuYaobang',
             4: 'JiangZeMin', 5: 'LiKeqiang', 6: 'MaoZedong', 7: 'WenJiabao',
             8: 'XijinPing', 9: 'Zhaoziyang'}


def check(total, sample):
    # total为全体，是一个字典类型
    # sample为样本，是一个图片格式，通过拍照获得
    image = face_recognition.load_image_file(sample)
    face_locations = face_recognition.face_locations(image)
    face_landmarks_list = face_recognition.face_landmarks(image)

    # 处理已知的名单
    known_image = []
    for i in os.listdir('leaderFaces'):
        known_image.append(
            face_recognition.load_image_file('leaderFaces/' + i))
    # 把已知人员全部加载为编码格式便于比对
    biden_encoding = []
    for i in known_image:
        biden_encoding = biden_encoding + face_recognition.face_encodings(i)

    # 处理读入的图片
    face_image_list = []
    results = []
    for face_location in face_locations:
        top, right, bottom, left = face_location
        face_image = image[top:bottom, left:right]
        face_image_list.append(face_image)
        unknown_encoding = face_recognition.face_encodings(face_image)[0]
        if True in face_recognition.compare_faces(biden_encoding, unknown_encoding, 0.5):
                 biden_encoding, unknown_encoding, 0.5).index(True)])
        else:
            results.append(False)

    return results

