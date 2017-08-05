"""
First Usage: th xxx.lua <path_of_parent_directory_of_data> <recursive_depth>
This script creates a image list based on the command line input
This assumes that the script is run as following:
python[3] xxxx.py parent_directory depth
where parent_directory
depth refers to how recursively down the parent directory the search is down
for depth of 1, it is equivalent to par_dir/*/*.suffix 

Second Usage: th xxx.lua <path_of_ancestor_directory_of_data> <recursive_depth_of_parent> <recursive_depth_of_data>
This script creates multiple image lists based on the command line inputs
where path_of_ancestor_directory_of_data refers to the ancestor directory, used to determine the common ancestors of all parents
recursive_depth_of_parent refers to how recursively doen the ancestor directory the parent directories are determined
recursive_depth_of_data refers to how recursively down the parent directory the search for data (images) is down

e.g.
path_of_ancestor_directory_of_data = ances/
recursive_depth_of_parent = 1
recursive_depth_of_data = 1

parents directories are determined by ances/*
for each parent directory,
a image list is created by seraching ances/parent/*/*.suffix
"""

import glob
import sys
import os

IMAGE_FILE_SUFFIX = '.jpg'
IMAGE_LIST_DIR = 'image_lists'

def get_all_directories_with_parent_directory_and_depth(parent_directory, depth):
    parents_list = [parent_directory]
    while(depth >= 1):
        parents_list = [os.path.join(parent, item) for parent in parents_list for item in next(os.walk(parent))[1]]
        depth -= 1
    return parents_list


def create_image_list_with_parent_directory_and_depth(parent_directory, depth = 1):
    depth_str = ''.join(['*/' for i in range(depth)])
    image_suffix = '*' + IMAGE_FILE_SUFFIX
    parent_directory = os.path.abspath(parent_directory) + '/'

    full_dir = parent_directory + depth_str + image_suffix
    if not (os.path.exists(IMAGE_LIST_DIR)):
        print('The output directory "' + IMAGE_LIST_DIR + '" does not exist, please create one.')
        return

    all_image_paths = sorted(glob.glob(full_dir))
    print(parent_directory)
    output_file_path = IMAGE_LIST_DIR + '/' + parent_directory[parent_directory.rfind('/', 0, len(parent_directory) - 1) + 1:-1] + 'img_list.txt'
    with open(output_file_path, 'w+') as file:
        for image_path in all_image_paths:
            file.write(image_path + '\n')
        file.close()
    print('Successfully written ' + str(len(all_image_paths)) + ' paths of images to the file "' + output_file_path + '" .')


if len(sys.argv) <= 2:
    print("Usage: th xxx.lua <path_of_parent_directory_of_data> <recursive_depth> \ne.g. th xxx.lua raw/all_images/ 1")
    print("Or\nth xxx.lua <path_of_ancestor_directory_of_data> <recursive_depth_of_parent> <recursive_depth_of_data>\n ")
    sys.exit()
elif len(sys.argv) <= 3:
    create_image_list_with_parent_directory_and_depth(sys.argv[1], int(sys.argv[2]))
else:
    parent_list = get_all_directories_with_parent_directory_and_depth(sys.argv[1], int(sys.argv[2]))
    # print(parent_list)
    for parent in parent_list:
        create_image_list_with_parent_directory_and_depth(parent, int(sys.argv[3]))
    # create_image_list_with_parent_directory_and_depth(sys.argv[1], int(sys.argv[2]))