#!/bin/bash

input=mfinal
output=mfinal

mkdir -p $output

rm $output/*


cat << EOF |./sordvtk
bigendian
$input
$output
1
static faultx faulty faultz 2001 801 1 10 n slip slip n af af n f0 f0 n fw fw n ll ll n trup trup n tarr tarr n faultz depth n tsm0 ts0 n tnm0 tn0
2
fault faultx faulty faultz 2001 801 1 91 0.5 1 6 n tsm ts n srm sr n ts1 ts1 n ts2 ts2 n ts3 ts3 n tnm tn
wave wfx wfy wfz 401 161 29 451 0.1 5 3 n v1 vx n v2 vy n v3 vz
EOF

####################################
input=mfinal_elastic
output=mfinal_elastcvtk

mkdir -p $output

rm $output/*


cat << EOF |./sordvtk
bigendian
$input
$output
1
static faultx faulty faultz 2001 801 1 10 n slip slip n af af n f0 f0 n fw fw n ll ll n trup trup n tarr tarr n faultz depth n tsm0 ts0 n tnm0 tn0
2
fault faultx faulty faultz 2001 801 1 91 0.5 1 6 n tsm ts n srm sr n ts1 ts1 n ts2 ts2 n ts3 ts3 n tnm tn
wave wfx wfy wfz 401 161 29 451 0.1 5 3 n v1 vx n v2 vy n v3 vz
EOF

####################################
input=mfinal_firstorder
output=mfinal_firstordervtk

mkdir -p $output

rm $output/*


cat << EOF |./sordvtk
bigendian
$input
$output
1
static faultx faulty faultz 2001 801 1 10 n slip slip n af af n f0 f0 n fw fw n ll ll n trup trup n tarr tarr n faultz depth n tsm0 ts0 n tnm0 tn0
2
fault faultx faulty faultz 2001 801 1 91 0.5 1 6 n tsm ts n srm sr n ts1 ts1 n ts2 ts2 n ts3 ts3 n tnm tn
wave wfx wfy wfz 401 161 29 451 0.1 5 3 n v1 vx n v2 vy n v3 vz
EOF
#slip faultx faulty faultz 2001 801 1 91 0.5 1 2 n slippath sl n sliptest su
#fault faultx faulty faultz 2001 801 1 91 0.5 1 6 n tsm ts n srm sr n ts1 ts1 n ts2 ts2 n ts3 ts3 n tnm tn
#wave wfx wfy wfz 401 161 29 401 0.1 5 3 n v1 vx n v2 vy n v3 vz
#plstrain fzx fzy fzz 401 161 41 91 0.5 1 1 c plstrain plstrain

####################################
input=mfinal_addupdip
output=mfinal_addupdipvtk

mkdir -p $output

rm $output/*


cat << EOF |./sordvtk
bigendian
$input
$output
1
static faultx faulty faultz 2001 801 1 10 n slip slip n af af n f0 f0 n fw fw n ll ll n trup trup n tarr tarr n faultz depth n tsm0 ts0 n tnm0 tn0
2
fault faultx faulty faultz 2001 801 1 91 0.5 1 6 n tsm ts n srm sr n ts1 ts1 n ts2 ts2 n ts3 ts3 n tnm tn
wave wfx wfy wfz 401 161 29 451 0.1 5 3 n v1 vx n v2 vy n v3 vz
EOF


####################################
input=mfinal_addupdip2
output=mfinal_addupdip2vtk

mkdir -p $output

rm $output/*


cat << EOF |./sordvtk
bigendian
$input
$output
1
static faultx faulty faultz 2001 801 1 10 n slip slip n af af n f0 f0 n fw fw n ll ll n trup trup n tarr tarr n faultz depth n tsm0 ts0 n tnm0 tn0
2
fault faultx faulty faultz 2001 801 1 91 0.5 1 6 n tsm ts n srm sr n ts1 ts1 n ts2 ts2 n ts3 ts3 n tnm tn
wave wfx wfy wfz 401 161 29 451 0.1 5 3 n v1 vx n v2 vy n v3 vz
EOF


########################################
input=mfinal_nofreesurface
output=mfinal_nofreesurfacevtk

mkdir -p $output
rm $output/*

cat << EOF |./sordvtk
bigendian
$input
$output
1
static faultx faulty faultz 2001 801 1 10 n slip slip n af af n f0 f0 n fw fw n ll ll n trup trup n tarr tarr n faultz depth n tsm0 ts0 n tnm0 tn0
2
fault faultx faulty faultz 2001 801 1 91 0.5 1 6 n tsm ts n srm sr n ts1 ts1 n ts2 ts2 n ts3 ts3 n tnm tn
wave wfx wfy wfz 401 161 81 451 0.1 5 3 n v1 vx n v2 vy n v3 vz
EOF