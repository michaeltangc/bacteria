#!/bin/bash

parent_dir="pass2_only"
for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
do
    ls $parent_dir/5_900$i/*.jpg > $parent_dir/5_900$i/test_5_900$i.txt
    sed -i -e "s/^/\/home\/bingbin\/bacteria\/data\/test\//" $parent_dir/5_900$i/test_5_900$i.txt
done
