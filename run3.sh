#!/bin/bash

input=mfinal
output=mfinalvtk

mkdir -p $output

#rm $output/*


cat << EOF |./sordvtk
bigendian
$input
$output
2
static faultx faulty faultz 2001 801 1 8 n slip slip n trup_0.01 trup n tarr_0.01 tarr n trup_0.1 trup2 n tarr_0.1 tarr2 n faultz depth n tsm0 ts0 n tnm0 tn0
plstrain fzx fzy fzz 2001 801 41 3 c plstrain plstrain c stry stry c strbar strbar
0
fault faultx faulty faultz 2001 801 1 91 0.5 1 6 n tsm ts n srm sr n ts1 ts1 n ts2 ts2 n ts3 ts3 n tnm tn
wave wavexslice waveyslice wavezslice 2001 1 145 451 0.1 5 3 n v1slice vx n v2slice vy n v3slice vz
EOF

#plstrain fzx fzy fzz 2001 801 41 3 c plstrain plstrain c stry stry c strbar strbar