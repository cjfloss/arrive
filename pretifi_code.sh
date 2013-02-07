#!/bin/sh
astyle --style=java -R "src/*.vala"
rm src/*.orig
rm src/*/*.orig
