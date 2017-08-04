"""
This script creates a image list based on the command line input
This assumes that the script is run as following:
python[3] xxxx.py parent_directory depth
where parent_directory
depth refers to how recursively down the parent directory the search is down
for depth of 1, it is equivalent to par_dir/*/*.suffix 
"""

import glob
import sys
import os

IMAGE_FILE_SUFFIX = '.jpg'
IMAGE_LIST_DIR = 'image_lists'

def create_image_list_with_parent_directory_and_depth(parent_directory, depth = 1):
    depth_str = ''.join(['*/' for i in range(depth)])
    image_suffix = '*' + IMAGE_FILE_SUFFIX
    parent_directory = os.path.abspath(parent_directory) + '/'

    full_dir = parent_directory + depth_str + image_suffix
    if not (os.path.exists(IMAGE_LIST_DIR)):
        print('The output directory "' + IMAGE_LIST_DIR + '" does not exist, please create one.')
        return

    all_image_paths = sorted(glob.glob(full_dir))
    output_file_path = IMAGE_LIST_DIR + '/' + parent_directory.replace('/', '_') + 'img_list.txt'
    with open(output_file_path, 'w+') as file:
        for image_path in all_image_paths:
            file.write(image_path + '\n')
        file.close()
    print('Successfully written ' + str(len(all_image_paths)) + ' paths of images to the file "' + output_file_path + '" .')


if len(sys.argv) < 2:
    print("Usage: th xxx.lua <path_of_parent_directory_of_data> <recursive_depth> \n e.g. th xxx.lua raw/all_images/ 1")
    sys.exit()
elif len(sys.argv) < 3:
    create_image_list_with_parent_directory_and_depth(sys.argv[1])
else:
    create_image_list_with_parent_directory_and_depth(sys.argv[1], int(sys.argv[2]))