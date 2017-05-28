import cv2
import numpy as np
import copy

prefix = 'Mar3/5_900'
f_ext = '.JPG'
img_list = ['01', '04', '05', '06', '17', '21', '22', '27']
r, g, b = 160, 50, 255
out_prefix = 'mask-{:d}-{:d}-{:d}/'.format(r,g,b)

for idx in img_list:
  fname = prefix + idx + f_ext
  print(fname)
  img = cv2.imread(fname)
  print(img.shape)
  h,w = img.shape[:2]
  
  for i in range(h):
      for j in range(w):
          if img[i][j][0]>r or img[i][j][1]>g or img[i][j][2]>b:
              img[i][j][0] = 255
              img[i][j][1] = 0
              img[i][j][2] = 0
  outfile = out_prefix + 'mask'+idx+'.jpg'
  print(outfile+'\n')
  cv2.imwrite(outfile, img)
  break
