#!/bin/bash
NUM_CLASSES=1
CLASSES="'RBC'"
#多个class写法：(class之间有逗号)
#CLASSES="'class1','class2','class3'"
# 注意还要修改一下my_data.yaml中的names的写法！！！

echo "
import os
import random

'''create path'''
if not os.path.exists('ImageSets/Main'):  # 改成自己建立的myData
    os.makedirs('ImageSets/Main')

'''create and open file'''
ftrainval = open('ImageSets/Main/trainval.txt', 'w')
ftrain = open('ImageSets/Main/train.txt', 'w')
fval = open('ImageSets/Main/val.txt', 'w')

'''train/trainval'''
xmlfilepath = 'Annotations/train'
total_xml = os.listdir(xmlfilepath)
num = len(total_xml)
list = range(num)
for i in list:
    name = total_xml[i][:-4] + '\n'
    ftrain.write(name)
    ftrainval.write(name)

'''val/trainval'''
xmlfilepath = 'Annotations/val'
total_xml = os.listdir(xmlfilepath)
num = len(total_xml)
list = range(num)
for i in list:
    name = total_xml[i][:-4] + '\n'
    fval.write(name)
    ftrainval.write(name)

'''close file'''
ftrainval.close()
ftrain.close()
fval.close()
" > Scripts/generate_ImageSets.py
python Scripts/generate_ImageSets.py

echo "
import xml.etree.ElementTree as ET
import pickle
import os
from os import listdir, getcwd
from os.path import join
train_sets = [('PascalVOC2022', 'train')]
val_sets = [('PascalVOC2022', 'val')]
classes = [$CLASSES]  # 改成自己的类别

if not os.path.exists('labels/train'):
    os.makedirs('labels/train')
if not os.path.exists('labels/val'):
    os.makedirs('labels/val')
if not os.path.exists('cfg/'):
    os.makedirs('cfg/')

def convert(size, box):
    dw = 1. / (size[0])
    dh = 1. / (size[1])
    x = (box[0] + box[1]) / 2.0 - 1
    y = (box[2] + box[3]) / 2.0 - 1
    w = box[1] - box[0]
    h = box[3] - box[2]
    x = x * dw
    w = w * dw
    y = y * dh
    h = h * dh
    return (x, y, w, h)


def convert_annotation(year, image_set,image_id):
    # 打开Annotations/train/1.xml(或者val)
    in_file = open('Annotations/%s/%s.xml' % (image_set,image_id))
    # 创建并打开labels/train/1.txt(或者val)
    out_file = open('labels/%s/%s.txt' % (image_set,image_id), 'w')
    tree = ET.parse(in_file)
    root = tree.getroot()
    size = root.find('size')
    w = int(size.find('width').text)
    h = int(size.find('height').text)

    for obj in root.iter('object'):
        difficult = obj.find('difficult').text
        cls = obj.find('name').text
        if cls not in classes or int(difficult) == 1:
            continue
        cls_id = classes.index(cls)
        xmlbox = obj.find('bndbox')
        b = (float(xmlbox.find('xmin').text), float(xmlbox.find('xmax').text), float(xmlbox.find('ymin').text),
             float(xmlbox.find('ymax').text))
        bb = convert((w, h), b)
        out_file.write(str(cls_id) + ' ' + ' '.join([str(a) for a in bb]) + '\n')

wd = getcwd()

# 创建labels/trian以及PascalVOC2022_train.txt
# year = PascalVOC2022;image_set=train
for year, image_set in train_sets:
    #打开并读取train.txt
    image_ids = open('ImageSets/Main/%s.txt' % (image_set)).read().strip().split()
    #创建PascalVOC2022_trian.txt
    list_file = open('cfg/%s_%s.txt' % (year, image_set), 'w')
    for image_id in image_ids:
        list_file.write('PascalVOC2022/JPEGImages/%s/%s.jpg\n' % (image_set,image_id))  #写入相对路径
        #list_file.write('%s/PascalVOC2022/JPEGImages/%s/%s.jpg\n' % (wd, image_set, image_id)) #写入绝对路径
        convert_annotation(year, image_set,image_id)
    list_file.close()

# 创建labels/val以及PascalVOC2022_val.txt
# year = PascalVOC2022;image_set=val
for year, image_set in val_sets:
    # 打开并读取val.txt
    image_ids = open('ImageSets/Main/%s.txt' % (image_set)).read().strip().split()
    # 创建PascalVOC2022_val.txt
    list_file = open('cfg/%s_%s.txt' % (year, image_set), 'w')
    for image_id in image_ids:
        list_file.write('PascalVOC2022/JPEGImages/%s/%s.jpg\n' % (image_set, image_id))  # 写入相对路径
        # list_file.write('%s/PascalVOC2022/JPEGImages/%s/%s.jpg\n' % (wd, image_set, image_id)) #写入绝对路径
        convert_annotation(year, image_set, image_id)
    list_file.close()
" > Scripts/xml2txt.py
python Scripts/xml2txt.py

echo "
#the path of train and val image set
train: PascalVOC2022/JPEGImages/train
val: PascalVOC2022/JPEGImages/val
# number of classes
# nc: $NUM_CLASSES #这里yolov5对比yolov3,不需要再写nc了
# class names
# names: [$CLASSES] ##这里yolov5对比yolov3,需要修改一下classes的写法（每一行一个种类，并且前面加上序号和冒号，形如：）
# names:
  #  0: person
  #  1: bicycle
  #  2: car
  #  3: motorcycle
  #  4: airplane
  #  5: bus
names:
  0: RBC
" >cfg/my_data.yaml

echo "
# YOLOv5 🚀 by Ultralytics, GPL-3.0 license

# Parameters
nc: $NUM_CLASSES  # number of classes
depth_multiple: 0.33  # model depth multiple
width_multiple: 0.50  # layer channel multiple
anchors:
  - [10,13, 16,30, 33,23]  # P3/8
  - [30,61, 62,45, 59,119]  # P4/16
  - [116,90, 156,198, 373,326]  # P5/32

# YOLOv5 v6.0 backbone
backbone:
  # [from, number, module, args]
  [[-1, 1, Conv, [64, 6, 2, 2]],  # 0-P1/2
   [-1, 1, Conv, [128, 3, 2]],  # 1-P2/4
   [-1, 3, C3, [128]],
   [-1, 1, Conv, [256, 3, 2]],  # 3-P3/8
   [-1, 6, C3, [256]],
   [-1, 1, Conv, [512, 3, 2]],  # 5-P4/16
   [-1, 9, C3, [512]],
   [-1, 1, Conv, [1024, 3, 2]],  # 7-P5/32
   [-1, 3, C3, [1024]],
   [-1, 1, SPPF, [1024, 5]],  # 9
  ]

# YOLOv5 v6.0 head
head:
  [[-1, 1, Conv, [512, 1, 1]],
   [-1, 1, nn.Upsample, [None, 2, 'nearest']],
   [[-1, 6], 1, Concat, [1]],  # cat backbone P4
   [-1, 3, C3, [512, False]],  # 13

   [-1, 1, Conv, [256, 1, 1]],
   [-1, 1, nn.Upsample, [None, 2, 'nearest']],
   [[-1, 4], 1, Concat, [1]],  # cat backbone P3
   [-1, 3, C3, [256, False]],  # 17 (P3/8-small)

   [-1, 1, Conv, [256, 3, 2]],
   [[-1, 14], 1, Concat, [1]],  # cat head P4
   [-1, 3, C3, [512, False]],  # 20 (P4/16-medium)

   [-1, 1, Conv, [512, 3, 2]],
   [[-1, 10], 1, Concat, [1]],  # cat head P5
   [-1, 3, C3, [1024, False]],  # 23 (P5/32-large)

   [[17, 20, 23], 1, Detect, [nc, anchors]],  # Detect(P3, P4, P5)
  ]

" >cfg/my_yolov5s.yaml
