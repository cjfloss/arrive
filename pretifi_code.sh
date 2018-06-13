#!/bin/sh
astyle --style=java -s4 -S -d -j -c -p -xg --lineend=linux -R "src/*.vala"
rm src/*.orig
rm src/*/*.orig
