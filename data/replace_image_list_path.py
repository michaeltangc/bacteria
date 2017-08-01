"""
This script replaces the paths in the image list to a new parent directory without the need to regenerate a new list from scratch

This assumes that the script is run as following:
python[3] xxx.py target_file target_directory backward_depth

The target_dirctory can be specified by relative path or absolute path, which refers to the new parent directory for the images

backward_depth refers to the part of the image path which is retained during replacement

for backward_depth of 1 and target_directory as '/new/'
it is equivalent to replace the original path from
'/home/old/a/b.jpg'
to
'/new/a/b.jpg'

Note that the retained part is kept as it is from the path, without changing any in-between directories

A new file with new suffix _path_updated will be generated
"""

import glob
import sys
import os

FILE_SUFFIX = '.txt'

def replace_image_path_with_retaining_depth(target_file, new_directory, retaining_backward_depth):
    content = ""
    with open(target_file, 'r+') as read_file:
        content = [line.strip('\n') for line in read_file.readlines()]
        read_file.close()
    output_file_path = target_file.replace(FILE_SUFFIX, '_path_updated' + FILE_SUFFIX)
    abs_new_directory = os.path.abspath(new_directory)

    with open(output_file_path, 'w+') as write_file:
        for line in content:
            write_file.write(abs_new_directory + get_remaining_part_of_path_by_backward_depth(line, retaining_backward_depth) + '\n')
        write_file.close()

    print('Successfully replaced paths for ' + str(len(content)) + ' images and exported to the file "' + output_file_path + '" .')

def get_remaining_part_of_path_by_backward_depth(path, backward_depth):
    ending_index = len(path)
    for i in range(backward_depth + 1):
        ending_index = path.rfind('/', 0, ending_index)
    return path[ending_index:]

if len(sys.argv) < 4:
    print('Please specify the target file, the new directory and the retaining depth as follows: \n python3 xxx.py <target_file> <new_dir> <retain_depth>')
    sys.exit()
else:
    replace_image_path_with_retaining_depth(sys.argv[1], sys.argv[2], int(sys.argv[3]))