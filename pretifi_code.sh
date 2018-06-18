#!/bin/sh
astyle --style=java -s4 -S -d -f -j -c -p -xb -xg --lineend=linux -R "src/*.vala"
rm src/*.orig
rm src/*/*.orig
