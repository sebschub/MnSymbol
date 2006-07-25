#!/bin/bash
for i in A B C D E F
do
  for j in "" "-Bold"
  do
    for k in 5 6 7 8 9 10 12
    do
      rm -f MnSymbol$i$j$k.[0-9]*
      ./mf2pt1.pl MnSymbol$i$j$k --encoding=../enc/MnSymbol$i.enc
      for k in MnSymbol$i$j$k.[0-9]*; do mv $k $k.eps;done
    done
  done
done

#for i in S S-Bold
#do
#  for j in 5 6 7 8 9 10 12
#  do
#    rm -f MnSymbol$i$j.[0-9]*
#    ./mf2pt1.pl MnSymbol$i$j --encoding=standardencoding
#    for k in MnSymbol$i$j.[0-9]*; do mv $k $k.eps;done
#    mftrace -f pfb MnSymbol$i$j
#  done
#done


#./gen-pfb.ff 2>&1|grep -v "showpage">errorlog

#for i in A B C D E F S 
#do
#  rm -f MnSymbol$i*.eps
#done

#rm *.tfm *.log *pk

