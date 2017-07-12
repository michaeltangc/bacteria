import cv2
import numpy as np
from sklearn.cluster import KMeans
from glob import glob

desc_all = np.empty((0,128))
for each in glob('square_lacto*.jpg'):
    img = cv2.imread(each)
    gray= cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

    sift = cv2.xfeatures2d.SIFT_create()
    kp, desc = sift.detectAndCompute(gray,None)
    desc_all = np.concatenate((desc_all, desc))

#     white = np.copy(img)
#     white.fill(1)
#     cv2.drawKeypoints(gray,kp, white, flags=cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
# 
#     cv2.imwrite(each.replace('square', 'sift_white'), white)

print('desc_all.shape:')
print(desc_all.shape)

kmeans = KMeans(n_clusters=100, random_state=0).fit(X)

