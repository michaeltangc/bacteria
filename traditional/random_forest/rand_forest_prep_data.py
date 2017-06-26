import cv2
import numpy as np

lines = [line.strip().split(' ') for line in open('/home/bingbin/bacteria/data/square224_white_bg/imgLst_square224_white_bg.txt', 'r').readlines()]
img_fnames = [line[0] for line in lines]
labels = [line[1] for line in lines]

imgDB = np.zeros([len(lines), 224*224], dtype=int)
for i,fname in enumerate(img_fnames):
    img = cv2.imread(fname)
    if len(img) != 224:
        img = img[:224, :224]
    imgDB[i] = img.reshape(1, 224*224)

