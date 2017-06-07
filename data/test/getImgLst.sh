#!/bin/bash

for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
do
    ls 5_900$i/*.jpg > 5_900$i/test_5_900$i.txt
    sed -i -e "s/^/\/home\/bingbin\/bacteria\/data\/test\//" 5_900$i/test_5_900$i.txt
done
