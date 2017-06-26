import cv2
import numpy as np
import copy

prefix = 'Mar3/5_900'
f_ext = '.JPG'
img_list = ['01', '04', '05', '06', '17', '21', '22', '27']
# idxes = [1, 4, 5, 6, 17, 21, 22, 27]

for idx in img_list:
  fname = prefix + idx + f_ext
  print(fname)
  img = cv2.imread(fname)
  print(img.shape)
  h,w = img.shape[:2]
  mask = copy.copy(img)
  
  for i in range(h):
      for j in range(w):
          if img[i][j][0]<160 and img[i][j][1]<50 and img[i][j][2]<160:
              mask[i][j][0] = 0
              mask[i][j][1] = 0
              mask[i][j][2] = 0
          else:
              mask[i][j][0] = 255
              mask[i][j][1] = 255
              mask[i][j][2] = 255
  cv2.imwrite('mask'+str(idx)+'.jpg', mask)
