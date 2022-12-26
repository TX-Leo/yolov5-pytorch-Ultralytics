PascalVOC2022 for yolov3-darknet
---
# JPEGImages
- 存放所有照片，主要分以下两个部分
  - train
    - 存放训练照片（0001.jpg）
  - val 
    - 存放验证照片（0001.jpg）

# Annotations
- 存放所有PascalVOC格式(.xml)的数据
  - train 
    - 存放训练PascalVOC数据(0001.xml)
  - val 
    - 存放验证PascalVOC数据(0001.xml)

# labels
- 存放所有YOLO格式(.txt)的数据
  - train 
    - 存放训练YOLO数据（0001.txt）
  - val 
    - 存放验证YOLO数据（0001.txt）

# cfg
## For yolov3-pytorch-Ultralytics
- my_data.yaml:数据文件
  - classes number
    - 检测的个数
  - names
    - 检测物体的名字（直接一个列表）
  - train path(PascalVOC2022/JPEGImages/train)
    - 训练照片的文件夹路径（也可以先写一个数据集的path，然后写train path的相对路径）
  - val path(PascalVOC2022/JPEGImages/val)
    - 验证照片的文件夹路径（也可以先写一个数据集的path，然后写val path的相对路径）
- my_yolov3-tiny.yaml:配置文件
  - my_yolov3.yaml/my_yolov3-tiny.yaml都可以(是从官方给的yolov3/yolov3-tiny.yaml上修改的，只需修改class)
- yolov3-tiny.pt:预权重文件
  - yolov3.pt/yolov3-tiny.pt/yolov3-spp.pt都可以 ,直接下载

# ImageSets
- Main
  - train.txt
    - 存放所有训练照片的名字（一行一个）
  - val.txt
    - 存放所有验证照片的名字（一行一个）
  - trainval.txt
    - 存放所有训练和验证照片的名字（一行一个）

# TestImages
- 存放待检测的照片(1.jpg) 
- output:存放检测后的照片结果

# Scripts
- 存放处理脚本
  - generate_ImageSets.py
    - 由Annotations(.xml)生成ImagesSets/Main里的内容
  - xml2txt.py
    - 由Annotations(.xml)生成labels里的内容，以及生成cfg/PascalVOC2022_train.txt和cfg/PascalVOC2022_val.txt
# Output
- val
- train
- detect
- output：用来存放训练结果
- weights：存放生成的权重文件（在预权重文件基础上训练生成的自己的权重文件）
  - best.pt:最好的一次权重文件
  - last.pt:上次生成的权重文件

# PascalVOC2022.sh
- 一键生成最终数据集

# 如何使用此数据集？
- 对于中间数据集，先```sourece PascalVOC2022.sh```
## 训练

```JSON
/Users/leo/opt/anaconda3/envs/yolov3-pytorch-ultralytics/bin/python train.py --data PascalVOC2022/cfg/my_data.yaml --cfg PascalVOC2022/cfg/my_yolov3-tiny.yaml --weights PascalVOC2022/cfg/yolov3-tiny.pt --epochs 5 --batch-size 4 --device 'cpu'  --project 'PascalVOC2022/Output/train' --name 'train_output'
```

## 测试

```JSON
/Users/leo/opt/anaconda3/envs/yolov3-pytorch-ultralytics/bin/python detect.py --weights PascalVOC2022/Output/train/train_output/weights/best.pt --source PascalVOC2022/TestImages/BloodImage_00350.jpg --device 'cpu'  --project 'PascalVOC2022/Output/detect' --name 'detect_output' --view-img --visualize
```

## 评估

```JSON
/Users/leo/opt/anaconda3/envs/yolov3-pytorch-ultralytics/bin/python val.py --data PascalVOC2022/cfg/my_data.yaml --weights PascalVOC2022/Output/train/train_output/weights/best.pt --batch-size 4 --project 'PascalVOC2022/Output/val' --name 'val_output' --half
```