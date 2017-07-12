import cv2
import time

t = time.clock()
mser = cv2.MSER_create()
mser.setPass2Only(True) # Pass2Only: only use the inverted image for detecting MSER
for i in range(1,32):
    img = cv2.imread('/home/bingbin/bacteria/data/Mar2/5_900{:02d}.JPG'.format(i))
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    white = gray.copy()
    white.fill(255)
    gray_inverted = white - gray # Invert the image s.t. Pass2Only will give the dark regions as desired
    regions = mser.detectRegions(gray_inverted, None)
    hulls = [cv2.convexHull(p.reshape(-1, 1, 2)) for p in regions]
    cv2.polylines(img, hulls, 1, (0,255,0), 2)
    cv2.imwrite('pass2_only/inverted_mser{:02d}.jpg'.format(i), img)
print((time.clock() - t) / 31)
