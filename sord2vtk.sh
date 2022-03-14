#!/bin/bash

input=refine_vol/out
output=refine_vol/vtk

mkdir -p $output

rm $output/*


cat << EOF |./sordvtk_r8
littleendian
$input
$output
ASCII
1
mesh x1 x2 x3 46 46 45 3 n x1 x1 n x2 x2 n x3 x3
1
wave x1 x2 x3 46 46 45 251 0.008 1 3 n a1 a1 n a2 a2 n a3 a3
EOF
