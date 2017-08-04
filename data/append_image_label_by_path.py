"""
This script automatically appends labels to the image lists by inspecting the image path

This assumes that the script is run as following:
python[3] xxxx.py target_file backward_depth

backward_depth refers to the part of the image path is matched against
for backward_depth of 1, it is equivalent to matching the 'xx' part in the following path: /aa/bb/cc/xx/dd.jpg
with a mapping of ('xx', 5), the above path would be assigned the label 5, appended after the path in a new file

The separator and matching mode can be set by changing the constants
"""

import glob
import sys
import os

FILE_SUFFIX = '.txt'
SEPARATOR = '=='
MATCHING_MODE = 4
PATH_NAME_LABEL_MAP = [
    ('lacto', 1),
    ('gardner', 2),
    ('bacte', 3),
    ('noise', 4)
    ]


def append_image_label_by_path_inspection(target_file, path_backward_depth = 1, path_name_label_map = []):

    content = ""
    with open(target_file, 'r+') as read_file:
        content = [line.strip('\n') for line in read_file.readlines()]
        read_file.close()
    output_file_path = target_file.replace(FILE_SUFFIX, '_labelled' + FILE_SUFFIX)
    
    with open(output_file_path, 'w+') as write_file:
        for line in content:
            write_file.write(line + SEPARATOR + str(get_mapping(get_part_of_path_by_backward_depth(line, path_backward_depth), path_name_label_map, MATCHING_MODE)) + '\n')
        write_file.close()

    print('Successfully appended labels for ' + str(len(content)) + ' images and exported to the file "' + output_file_path + '" .')

def get_part_of_path_by_backward_depth(path, backward_depth):
    return path.split('/')[-1 * backward_depth - 1]

def get_mapping(target, mapping_list, mode = 1):
    """ 
    modes:
    1 - exact match
    2 - target appears in mappings check
    3 - mappings appears in target check
    4 - both ways appearance check
    """
    if mode == 1:
        for mapping in mapping_list:
            if (mapping[0] == target):
                return mapping[1]
    elif mode == 2:
        for mapping in mapping_list:
            if (target in mapping[0]):
                return mapping[1]
    elif mode == 3:
        for mapping in mapping_list:
            if (mapping[0] in target):
                return mapping[1]
    elif mode == 4:
        for mapping in mapping_list:
            if (mapping[0] in target) or (target in mapping[0]):
                return mapping[1]
    return None


if len(sys.argv) < 3:
    print("Usage: th xxx.lua <target_file_path> <reverse_mapping_depth> \n e.g. th xxx.lua image_lists/list.txt 1")
    print('Please specify the target file and the mapping depth')
    sys.exit()
else:
    append_image_label_by_path_inspection(sys.argv[1], int(sys.argv[2]), PATH_NAME_LABEL_MAP)