import cv2
import numpy as np
from sklearn.cluster import DBSCAN
from sklearn import metrics
import time

def main(prefix, f_ext, img_list, r,g,b, out_prefix):
    for idx in img_list:
        t_start = time.clock()
        fname = prefix + idx + f_ext
        print('\n'+fname)
        img = cv2.imread(fname)
        print(img.shape)
        h,w = img.shape[:2]
        
        # Form a set of data points
        data = []
        for i in range(h):
            for j in range(w):
                too_red = img[i][j][2]>r
                dark_red = (img[i][j][2]>140 and img[i][j][0]<30 and img[i][j][1]<70)
                too_bright = int(img[i][j][0])+int(img[i][j][1])+int(img[i][j][2]) > 480
                if not(too_red or dark_red or too_bright):
                    data.append([i,j])
    
        print('# total pixels: ' + str(len(data)))
        # DBSCAN to form clusters
        data_array = np.array(data)
        db = DBSCAN(eps=5, min_samples=50, metric='euclidean').fit(data_array)
        labels = db.labels_
        n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
        print('# of clusters: ' + str(n_clusters))
        print('# of core samples: ' + str(len(set(db.core_sample_indices_))) )

        clusters = [data_array[labels==i] for i in xrange(n_clusters)]
        centers = []
        for i,each in enumerate(clusters):
            size = len(each)
            avg_i, avg_j = each.mean(0)
            centers.append([avg_i, avg_j])
            print('#{:d} (size={:d}): ({:f}, {:f})'.format(i, size, avg_i, avg_j))

        # Mark results on the original image
        for [ci,cj] in centers:
            # range_i = range(max(0, i-5), min(h, i+5))
            # range_j = range(max(0, j-5), min(w, j+5))
            for i in range(max(0, int(ci-2)), min(h, int(ci+2))):
                for j in range(max(0, int(cj-2)), min(w, int(cj+2))):
                    img[i][j][0], img[i][j][1], img[i][j][2] = 0,255,0
        outfile = out_prefix + 'mask'+idx+'.jpg'
        print(outfile)
        print(time.clock()-t_start)
        cv2.imwrite(outfile, img)
        break

prefix = 'Mar3/5_900'
f_ext = '.JPG'
#img_list = ['01', '04', '05', '06', '14', '15', '17', '21', '22', '27']
img_list = ['05', '22']
r, g, b = 180, 255, 255
# out_prefix = 'mask-{:d}-{:d}-{:d}/'.format(r,g,b)
out_prefix = 'dbscan/'

main(prefix, f_ext, img_list, r,g,b, out_prefix)
