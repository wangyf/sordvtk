#!/bin/bash

input=new_plasticity_aftershock
output=new_plasticity_aftershock_vtk

mkdir -p $output

rm $output/*


cat << EOF |./sordvtk
bigendian
$input
$output
9
setup faultx faulty faultz 2001 801 1 5 n af af n f0 f0 n fw fw n ll ll n faultz depth
static faultx faulty faultz 2001 801 1 5 n slip slip n tsm0 tsm0 n tnm0 tnm0 n tsme tsme n tnme tnme n trup trup n tarr tarr
plstrain fzx fzy fzz 2001 801 41 1 c plstrain plstrain 
plmt11 fzx fzy fzz 2001 801 41 1 c plmt11 plmt11 
plmt22 fzx fzy fzz 2001 801 41 1 c plmt22 plmt22 
plmt33 fzx fzy fzz 2001 801 41 1 c plmt33 plmt33 
plmt12 fzx fzy fzz 2001 801 41 1 c plmt12 plmt12 
plmt23 fzx fzy fzz 2001 801 41 1 c plmt23 plmt23 
plmt31 fzx fzy fzz 2001 801 41 1 c plmt31 plmt31 
0
EOF
