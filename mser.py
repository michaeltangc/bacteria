import cv2
img = cv2.imread('Mar3/5_90002.JPG')
mser = cv2.MSER_create()
gray_img = img.copy()
gray = cv2.cvtColor(gray_img, cv2.COLOR_BGR2GRAY)
regions = mser.detectRegions(gray, None)
hulls = [cv2.convexHull(p.reshape(-1, 1, 2)) for p in regions]
cv2.polylines(img, hulls, 1, (0,255,0), 2)
cv2.imwrite('mser.jpg', img)
print(len(hulls))
