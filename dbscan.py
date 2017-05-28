# Image
import cv2
from PIL import ImageFont
from PIL import Image
from PIL import ImageDraw
# Stats
import numpy as np
from sklearn.cluster import DBSCAN
from sklearn import metrics
from sklearn.decomposition import PCA
# Misc
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
    
        # DBSCAN
        data_array = np.array(data)
        db = DBSCAN(eps=5, min_samples=50, metric='euclidean').fit(data_array)
        labels = db.labels_
        n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
        print('# total pixels: ' + str(len(data)))
        print('# of clusters: ' + str(n_clusters))
        print('# of core samples: ' + str(len(set(db.core_sample_indices_))) )

        # PCA
        clusters = [data_array[labels==i] for i in xrange(n_clusters)]
        centers = []
        pcas = []
        pca = PCA(n_components=2)
        for i,each in enumerate(clusters):
            size = len(each)
            avg_i, avg_j = each.mean(0)
            pca.fit(each)
            var1, var2 = pca.explained_variance_ratio_
            centers.append([avg_i, avg_j])
            pcas.append([var1, var2])
            print('#{:d} (size={:d}): center=({:f}, {:f}) / var=({:f}, {:f})'.format(i, size, avg_i, avg_j, var1, var2))

        # Mark results on the original image
        # 1. mark clusters by green dots
        for [ci,cj] in centers:
            for i in range(max(0, int(ci-5)), min(h, int(ci+5))):
                for j in range(max(0, int(cj-5)), min(w, int(cj+5))):
                    img[i][j][0], img[i][j][1], img[i][j][2] = 0,255,0
        # 2. add texts showing PCA variances
        img_draw = Image.fromarray(img[:,:,[2,1,0]]) # Note: rearrange color channels: BGR -> RGB
        draw = ImageDraw.Draw(img_draw, mode='RGB')
        for i in range(n_clusters):
            draw.text((int(centers[i][1]), int(centers[i][0])), "({:d}, {:d}): ({:f}, {:f})".format(int(centers[i][0]), int(centers[i][1]), pcas[i][0], pcas[i][1]), fill=(0,0,0))
        # 3. write to file
        outfile = out_prefix + 'mask'+idx+'_text.jpg'
        img_draw.save(outfile)
        # cv2.imwrite(outfile, img)
        print(outfile)
        print(time.clock()-t_start)
        break

prefix = 'Mar3/5_900'
f_ext = '.JPG'
#img_list = ['01', '04', '05', '06', '14', '15', '17', '21', '22', '27']
img_list = ['05', '22']
r, g, b = 180, 255, 255
# out_prefix = 'mask-{:d}-{:d}-{:d}/'.format(r,g,b)
out_prefix = 'dbscan/'

main(prefix, f_ext, img_list, r,g,b, out_prefix)
