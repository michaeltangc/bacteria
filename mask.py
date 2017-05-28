import cv2
import numpy as np
import time

prefix = 'Mar3/5_900'
f_ext = '.JPG'
#img_list = ['01', '04', '05', '06', '17', '21', '22', '27']
img_list = ['14', '15']
r, g, b = 180, 255, 255
# out_prefix = 'mask-{:d}-{:d}-{:d}/'.format(r,g,b)
out_prefix = 'mask-r180-r140g70b30-sum480/'

for idx in img_list:
    t_start = time.clock()
    fname = prefix + idx + f_ext
    print('\n'+fname)
    img = cv2.imread(fname)
    # print(img.shape)
    h,w = img.shape[:2]
    
    for i in range(h):
        for j in range(w):
            too_red = img[i][j][2]>r
            dark_red = (img[i][j][2]>140 and img[i][j][0]<30 and img[i][j][1]<70)
            too_bright = int(img[i][j][0])+int(img[i][j][1])+int(img[i][j][2]) > 480
            if too_red or dark_red or too_bright:
                img[i][j][0] = 255
                img[i][j][1] = 255
                img[i][j][2] = 255
    outfile = out_prefix + 'mask'+idx+'.jpg'
    print(outfile)
    print(time.clock()-t_start)
    cv2.imwrite(outfile, img)
