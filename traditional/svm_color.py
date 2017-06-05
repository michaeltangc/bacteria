from sklearn import svm, tree

# SVM to distinguish where a pixel belongs to a bacteria or not

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

# clf = svm.SVC(probability=True)
clf = tree.DecisionTreeClassifier()
clf.fit(goodColors+badColors, labels)

print(clf)

newBad = [[174, 147, 105], [163, 103, 14], [154, 56, 47], [180, 106, 102], [165, 81, 42]]
# newGood = [[63, 8, 42], [36, 18, 37], [65, 35, 60], [82, 98, 132], [46, 55, 99]]
newGood = [[63,8,42]]

print('newBad:')
print(clf.predict(newBad))
print('\nnewGood:')
print(clf.predict(newGood))
