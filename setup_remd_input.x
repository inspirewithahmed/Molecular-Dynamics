#!/bin/bash -f
# update D1_Ref with actual D1_Ref
if [ -f groupfile ];
then
  rm groupfile
fi

if [ -f remd.groupfile ];
then
  rm remd.groupfile
fi

nrep=`wc temperature.dat | awk '{print $1}'`
echo $nrep
count=0
for TEMP in `cat temperature.dat`
do
  let COUNT+=1
  REP=`printf "%03d" $COUNT`
  echo "TEMPERATURE: $TEMP K ==> FILE: remd.mdin.$REP"
  sed "s/XXXXX/$TEMP/g" remd.mdin > temp
  sed "s/RANDOM_NUMBER/$RANDOM/g" temp > remd.mdin.$REP
  echo "-O -rem 1 -remlog rem.log -i remd.mdin.$REP -o remd.mdout.$REP -c equilibrate.rst.$REP -r remd.rst.$REP -x remd.mdcrd.$REP -inf remd.mdinfo.$REP -p D1Cl1_TR.prmtop" >> remd.groupfile
  
  rm -f temp
done
echo "#" >> groupfile

echo "N REPLICAS  = $nrep"
echo " Done."


