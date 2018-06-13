#!/bin/sh
astyle --style=java -s4 -S -d -p -xg -R "src/*.vala"
rm src/*.orig
rm src/*/*.orig
