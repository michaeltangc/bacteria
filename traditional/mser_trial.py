import cv2
import time

t = time.clock()
for i in range(1,32):
    img = cv2.imread('../data/Mar2/5_900{:02d}.JPG'.format(i))
    mser = cv2.MSER_create(_max_area=1500)
    gray_img = img.copy()
    gray = cv2.cvtColor(gray_img, cv2.COLOR_BGR2GRAY)
    regions = mser.detectRegions(gray, None)
    print(len(regions))
    # print(len(regions[0]))
    # print(regions[0][0])
    hulls = [cv2.convexHull(p.reshape(-1, 1, 2)) for p in regions]
    cv2.polylines(img, hulls, 1, (0,255,0), 2)
    cv2.imwrite('../../result/mser/maxArea1500/mser{:02d}.jpg'.format(i), img)
# print((time.clock() - t) / 31)