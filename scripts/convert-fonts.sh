#!/bin/bash
cd ..
patch -p1 < scripts/patch_mf_sources
cd source

for i in A B C D E F
do
  for j in "" "-Bold"
  do
    for k in 5 6 7 8 9 10 12
    do
      rm -f MnSymbol$i$j$k.[0-9]*
      ../scripts/mf2pt1.pl MnSymbol$i$j$k --encoding=../enc/MnSymbol$i.enc
      for k in MnSymbol$i$j$k.[0-9]*; do mv $k $k.eps;done
    done
  done
done

cd ../scripts/
mkdir finalpfb
for i in "" "-Bold"
do 
  for j in 5 6 7 8 9 10 12
  do
    ./mkMn.ff $j $i 2>&1 | grep -v showpage
    ./postprocess.ff $j $i
    t1disasm MnSymbol$i$j.pfb | gawk -f packsubr.awk | t1asm -b > finalpfb/MnSymbol$i$j.pfb
  done
done

