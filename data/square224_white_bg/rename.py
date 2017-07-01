from glob import glob
import os

os.chdir('lacto')
for fname in glob('*.jpg'):
    os.rename(fname, fname.replace('mask', 'lacto_mask'))

os.chdir('../gardner')
for fname in glob('*.jpg'):
    os.rename(fname, fname.replace('mask', 'gardner_mask'))

os.chdir('../bacte')
for fname in glob('*.jpg'):
    os.rename(fname, fname.replace('mask', 'bacte_mask'))

os.chdir('../noise')
for fname in glob('*.jpg'):
    os.rename(fname, fname.replace('mask', 'noise_mask'))
