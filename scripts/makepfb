#!/bin/bash

for x in A B C D E F S
do
  for y in "" "-Bold"
  do
    for z in 5 6 7 8 9 10 12
    do
      mftrace -b -e ../enc/MnSymbol$x.enc MnSymbol$x$y$z
    done
  done
done

fontforge scripts/merge-fonts.ff

