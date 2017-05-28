import cv
import copy

img = cv.imread('5_90021.JPG')
mask = copy.copy(img)
print(len(img))