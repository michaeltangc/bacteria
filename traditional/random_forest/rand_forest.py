from sklearn.ensemble import RandomForestClassifier
import numpy as np
import cv2

def prep_data(imgLst, isTrain):
    lines = [line.strip().split(' ') for line in open(imgLst, 'r').readlines()]
    img_fnames = [line[0] for line in lines]
    labels = []
    if isTrain:
        labels = [int(line[1]) for line in lines]
    
    imgDB = np.zeros([len(lines), 224*224], dtype=int)
    for i,fname in enumerate(img_fnames):
        img = cv2.imread(fname, 0)
        if len(img) != 224:
            img = img[:224, :224]
        imgDB[i] = img.reshape(1, 224*224)
    return imgDB, img_fnames, labels

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

    interpretation = 'Normal' if score<=3 else ('BV' if score>=7 else 'Interm')
    return score, interpretation


# Init a random forest instance
randForest = RandomForestClassifier()

# Training
imgLst_train = '/home/bingbin/bacteria/data/square224_white_bg/imgLst_square224_white_bg.txt'
imgDB, _, labels = prep_data(imgLst_train, True)
randForest.fit(imgDB, labels)
# check training accuracy
predicted_labels = randForest.predict(imgDB)
match = [0 if a != b else 1 for (a,b) in zip(labels, predicted_labels)]
print('Training Accuracy: {:d} / {:d} = {:f}'.format(sum(match), len(labels), float(sum(match))/len(labels)))

# Testing
for i in range(1,32):
    imgLst_test = '/home/bingbin/bacteria/data/test/5_900{:02d}/test_5_900{:02d}.txt'.format(i, i)
    imgDB, img_fnames, _ = prep_data(imgLst_test, False)
    result = randForest.predict(imgDB)
    outname = 'result/detail2/5_900{:02d}.txt'.format(i)
    cnt = [0,0,0,0]
    with open(outname, 'w') as fout:
        for i, label in enumerate(result):
            fout.write(img_fnames[i] + ' ' + str(label) + '\n')
            cnt[label-1] = cnt[label-1] + 1
    score, interpretation = nugent(cnt[0], cnt[1], cnt[2])
    # Format: lacto_cnt gardner_cnt bacte_cnt noise_cnt / nugent_score interpretation
    print('{:d} {:d} {:d} {:d} / {:d} '.format(cnt[0], cnt[1], cnt[2], cnt[3], score) + interpretation)


