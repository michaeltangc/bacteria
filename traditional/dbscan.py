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
from sklearn import tree
# Misc
import time
import copy

verbose = True
debug = False

def main(prefix, f_ext, img_list, r,g,b, out_prefix):
    t_DBSCAN, t_PCA, t_draw = 0, 0, 0
    clf = DTColor()
    for idx in img_list:
        t_start = time.clock()
        fname = prefix + idx + f_ext
        print('\n'+fname)
        img = cv2.imread(fname)
        h,w = img.shape[:2]
        if debug:
            print('h = {:d} / w = {:d}'.format(h, w))
         
        # Form a set of data points
        data = []
        mask = copy.copy(img)
        for i in range(h):
            t_row = time.clock()
            for j in range(w):
                too_red = img[i][j][2]>180
                dark_red = (img[i][j][2]>140 and img[i][j][0]<50 and img[i][j][1]<80)
                too_bright = int(img[i][j][0])+int(img[i][j][1])+int(img[i][j][2]) > 450
                # if too_red or clf.predict([[img[i][j][2], img[i][j][1], img[i][j][0]]])[0]==0:
                if too_red or dark_red or too_bright:
                    mask[i][j][0], mask[i][j][1], mask[i][j][2] = 255, 255, 255
                else:
                    data.append([i,j])
            if debug:
                print('Row #{:d}: {:f}s'.format(i, time.clock()-t_row))
    
        # DBSCAN
        tmp = time.clock()
        data_array = np.array(data)
        if debug:
            print('About to perform DBSCAN')
        db = DBSCAN(eps=7, min_samples=50, metric='euclidean').fit(data_array)
        if debug:
            print('DBSCAN finished')
        labels = db.labels_
        n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
        if verbose:
            print('# total pixels: ' + str(len(data)))
            print('# of clusters: ' + str(n_clusters))
            print('# of core samples: ' + str(len(set(db.core_sample_indices_))) )
        t_DBSCAN = t_DBSCAN + time.clock() - tmp

        # PCA
        tmp = time.clock()
        clusters = [data_array[labels==i] for i in xrange(n_clusters)]
        centers = []
        vars = []
        ratios = []
        pca = PCA(n_components=2)
        for i,each in enumerate(clusters):
            size = len(each)
            avg_i, avg_j = each.mean(0)
            pca.fit(each)
            var1, var2 = pca.explained_variance_
            ratio1, ratio2 = pca.explained_variance_ratio_
            centers.append([avg_i, avg_j])
            vars.append([var1, var2])
            ratios.append([ratio1, ratio2])
            if verbose:
                print('#{:d} (size={:d}): center=({:f}, {:f}) / var=({:f}, {:f}) /  ratio=({:f}, {:f})'.format(i, size, avg_i, avg_j, var1, var2, ratio1, ratio2))
        t_PCA = t_PCA + time.clock() - tmp

        # Mark on the original image + count results
        t_draw = time.clock()
        lacto, gardner, others = 0, 0, 0
        typ = 'Others'
        txt = []
        for i in range(n_clusters):
            color = [0,0,0] # channels: BGR
            if vars[i][0] > 200 and ratios[i][0] > 0.95:
                lacto = lacto + 1
                typ = 'Lacto'
                color = [0,255,0]
            elif ratios[i][0] > 0.7: # rod shape
                gardner = gardner + 1
                typ = 'Gardner'
                color = [0,0,255]
            else:
                others = others + 1 # e.g. coccus
                typ = 'Others'
                color = [255,0,0]
            ci, cj = centers[i]
            # Mark cluster center (color-coded)
            for di in range(max(0, int(ci-5)), min(h, int(ci+5))):
                for dj in range(max(0, int(cj-5)), min(w, int(cj+5))):
                    img[di][dj][0], img[di][dj][1],img[di][dj][2] = color[0], color[1], color[2]
                    mask[di][dj][0], mask[di][dj][1], mask[di][dj][2] = color[0], color[1], color[2]
            txt.append("{:s}: {:f} / {:f}".format(typ, vars[i][0], ratios[i][0]))
        img_draw = Image.fromarray(img[:,:,[2,1,0]]) # rearrange channels: RGB->BGR
        draw_img = ImageDraw.Draw(img_draw, mode='RGB')
        mask_draw = Image.fromarray(mask[:,:,[2,1,0]])
        draw_mask = ImageDraw.Draw(mask_draw, mode='RGB')
        for i in range(n_clusters):
            draw_img.text((int(centers[i][1]), int(centers[i][0])), txt[i], fill=(0,0,0))
            draw_mask.text((int(centers[i][1]), int(centers[i][0])), txt[i], fill=(0,0,0))

        # Write to file
        outImg = out_prefix + 'img'+idx+'.jpg'
        img_draw.save(outImg)
        outMask = out_prefix + 'mask'+idx+'.jpg'
        mask_draw.save(outMask)
        t_draw = t_draw + time.clock() - tmp

        # Show results on the terminal
        score, condition = nugent(lacto, gardner, others)
        print(outImg + ': {:s}(score={:d}): lacto: {:d} / gardner: {:d} / others: {:d}'.format(condition, score, lacto, gardner, others))
        if verbose: print(time.clock()-t_start)
    num_img = len(img_list)
    print('Avg time: DBSCAN {:f}s / PCA {:f}s / draw {:f}s'.format(t_DBSCAN/num_img, t_PCA/num_img, t_draw/num_img))
    return

def DTColor():
    fgood = open('color_good', 'r')
    goodColors = []
    for line in fgood.readlines():
        colors = map(int, line.replace('\n', '').split(' '))
        goodColors.append(colors)
    fgood.close()

    fbad = open('color_bad', 'r')
    badColors = []
    for line in fbad.readlines():
        colors = map(int, line.replace('\n', '').split(' '))
        badColors.append(colors)
    fbad.close()

    labels = [1]*len(goodColors) + [0]*len(badColors)

    print('About to get DT')
    clf = tree.DecisionTreeClassifier(min_impurity_split=1e-6)
    clf.fit(goodColors+badColors, labels)
    print('Finished constructing decision tree for color s')
    return clf


def nugent(lacto, gardner, others):
    score = 0
    # Lactobacillus
    if lacto == 0:
        score = score + 4
    elif lacto == 1:
        score = score + 3
    elif lacto <= 4:
        score = score + 2
    elif lacto <= 30:
        score = score + 1
    # Gardnerella vaginalis
    if gardner > 30:
        score = score + 4
    elif gardner >= 5:
        score = score + 3
    elif gardner > 1:
        score = score + 2
    elif gardner == 1:
        score = score + 1
    # TODO: Others: curved rods vs coccus
   
    condition = 'Normal' if score<=3 else ('BV' if score>=7 else 'Interm')
    return score, condition


prefix = '5_900'
f_ext = '.JPG'
img_list = []
for i in range(1, 32):
    img_list.append('{:02d}'.format(i))
r, g, b = 180, 255, 255
# out_prefix = 'mask-{:d}-{:d}-{:d}/'.format(r,g,b)
out_prefix = 'color_coded_'

main(prefix, f_ext, ['17'], r,g,b, out_prefix)
