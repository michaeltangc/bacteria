import cv2
from glob import glob
import numpy as np
import time
import os

cnt = 0

def cropRegion(outname, img, mser, prefix, outsize):
	t_total = time.clock()
	region_cnt = 0
	area = 0
	w,h = 0,0
	gray_img = img.copy()
	gray = cv2.cvtColor(gray_img, cv2.COLOR_BGR2GRAY)

	regions = mser.detectRegions(gray, None)
	boxes = np.empty([len(regions), 4], dtype=int)
	for i, region in enumerate(regions):
		boxes[i][0:2] = np.amin(region, axis=0)
		boxes[i][2:4] = np.amax(region, axis=0)
		region_cnt = region_cnt + 1

	# NMS
	t_nms = time.clock()
	# print('# boxes:' + str(len(boxes)))
	boxes, idx = nms(boxes)
	new_regions = []
	for i in idx:
		new_regions.append(regions[i])

	# print('# boxes (after NMS):' + str(len(boxes)))
	hulls = [cv2.convexHull(p.reshape(-1, 1, 2)) for p in new_regions]
	hull_img = img.copy()
	cv2.polylines(hull_img, hulls, 1, (0,255,0), 2)
	# NOTE: remember to update the file name
	cv2.imwrite(outname, hull_img)
	# print('NMS time = ' + str(time.clock() - t_nms))

	t_crop = time.clock()
	global cnt
	for i,box in enumerate(boxes):
		# NOTE: remember to update the path
		size = max(box[3]-box[1], box[2]-box[0])+1
		# print('box:')
		# print(box)
		mask = np.full([size,size,3], 255, dtype=int)
		# print('size = ' + str(size))
		for [ptj, pti] in new_regions[i]:
			# print('i: ' + str(pti-box[1]) + ' / j: ' + str(ptj-box[0]))
			mask[pti-box[1], ptj-box[0]] = img[pti, ptj]
		padded = np.array([[[255]*3]*outsize]*outsize, dtype=int)
		if size < outsize:
			w_start, h_start = int((outsize-size)/2), int((outsize-size)/2)
			padded[h_start:(h_start+size), w_start:(w_start+size)] = mask
		else:
			padded = mask
		cv2.imwrite(prefix+'{:06d}.jpg'.format(cnt), padded)
		cnt = cnt + 1
	# print('Save time = ' + str(time.clock() - t_crop))

	# print('Total time = ' + str(time.clock() - t_total) + '\n')
	# print('Avg w: ' + str(w/region_cnt))
	# print('Avg h: ' + str(h/region_cnt))
	# print('Avg area: ' + str(area/region_cnt))

def nms(boxes):
	x1, y1, x2, y2 = boxes[:, 0], boxes[:, 1], boxes[:, 2], boxes[:, 3]
	areas = (x2 - x1 + 1) * (y2 - y1 + 1)
	order = areas.argsort()[::-1]
	nboxes = boxes.shape[0]
	suppressed = np.zeros((nboxes), dtype=np.int)

	keep = []
	for _i in range(nboxes):
		i = order[_i]
		if suppressed[i] == 1:
			continue
		keep.append(i)
		ix1, iy1, ix2, iy2 = x1[i], y1[i], x2[i], y2[i]
		iarea = areas[i]
		for _j in range(_i + 1, nboxes):
			j = order[_j]
			if suppressed[j] == 1:
				continue
			xx1, yy1, xx2, yy2 = max(ix1, x1[j]), max(iy1, y1[j]), min(ix2, x2[j]), min(iy2, y2[j])
			w = max(0.0, xx2 - xx1 + 1)
			h = max(0.0, yy2 - yy1 + 1)
			inter = w*h
			over = inter / min(iarea, areas[j]) # (iarea + areas[j] - inter)
			if over >= 0.8:
				suppressed[j] = 1
	return boxes[np.array(keep)], keep


size = 224 # size of the padded square
mser = cv2.MSER_create(_max_variation=0.3, _max_area=2000)

dirs = ['../data/Apr19th/Lactobacilli', '../data/Apr19th/Gardnerella'] #, '../data/Apr19th/Bacteroides']
# dirs = ['2017-03-02 Meeting/']
for each in dirs:
	cnt = 0
	os.chdir(each)
        bacteria_name = each[each.rfind('/')+1:]
	result_dir = '/home/bingbin/bacteria/data/square224_white_bg/' + bacteria_name + '/'
        orig_dir = result_dir + 'masked_orig_img/'
	if not os.path.exists(result_dir):
		os.mkdir(result_dir)
                os.mkdir(orig_dir)
	for fname in glob('*.JPG'):
		# subdir = fname.replace('.JPG', '')
		# if not os.path.exists(subdir):
		# 	os.mkdir(subdir)
		prefix = result_dir + ('lacto' if bacteria_name == 'Lactobacilli' else 'gardner') + '_mask_square'
		outname = orig_dir + fname.replace('.JPG', '_mask.JPG')
		img = cv2.imread(fname) # dim = h * w * 3
		cropRegion(outname, img, mser, prefix, size)
	os.chdir('../../')
