# THIS FILE BELONGS TO THE METATYPE1 PACKAGE
#
# It is an AWK script for ``subroutine packing'' in Type 1 fonts;
# an algorithm for finding the longest repeating substring is exploited
# 31.07.2002, v. 0.1: first numbered version; banner added, VERBOSE introduced 

BEGIN {
 CONSOLE="/dev/stderr"
# for MS-DOS you may use:
#  CONSOLE="CON"
  ini_chstr()
  if (LEV=="") LEV=5 # default number of lines of the shortest chunk
  if (VERBOSE=="") VERBOSE=1
  if ((VERBOSE!=0) && (VERBOSE!=1) && (VERBOSE!=2)) VERBOSE=2
  verbose_mess(0.5,
    "This is packsubr, ver. 0.1 (a packer of subroutines in PS Type 1 fonts)")
}

/./ {
  T[++T[0]]=$0 # T -- table containing lines of the font
  if ($NF in chstr) {
    # X -- ``alphabet of lines''; the input lines are unequivocally
    #      numbered -- identical lines receive the same number
    #      (X[line] = such a number) it is used only during
    #      the reading of the font
    # C[i] sequence to be analysed
    # L[i] the number of line in the input file that corresponds to C[i];
    #      in other words: C[i]=X[T[L[i]]], i.e., the line T[L[i]] received
    #      the number C[i]
    # F[i] frequency of a given ``symbol''
    L[++n]=T[0]; if ($0 in X) {C[n]=X[$0]} else C[n]=X[$0]=n
    F[C[n]]++; p=1
  } else if (p) {C[n]=++n # not: C[++n]=n (gues why ;-)
    F[n]=1; p=0
  }
}

/^\/Subrs/ {
  if (subrs_beg>0) {odd_font=FILENAME; exit}; subrs_beg=T[0]; subrs_sofar=$2
}
(subrs_end==0) && (/^ND/ || /^\|-/) {subrs_end=T[0]}

END {
  if (odd_font) {mess("Odd font: " odd_font); exit}

  # ``primary parameters'':
  # C -- classes, F -- frequency
  # L -- line numbers
  # T -- text of font
  # n -- number of ,,good'' line in font
  #
  step=1; verbose_messf(1, "STEP " step)
  prepare_list(n,C,F,N,P)
  while ((k=output_classes(step,n,C,F,L,N,R))>0) {
    verbose_mess(1.5,", found " k " items")
    verbose_messf(1, "STEP " ++step); next_step(n,C,F,N,P);
  }
  verbose_mess(1.5, ", no items found")
  if (VERBOSE==1) print "" > CONSOLE
#
  find_subrs(step-1,R,O,Q,S)
  verbose_mess(0.5,
    "Subroutines found: source " subrs_sofar+0 ", new " 0+S[0] ".")
  flush_font(subrs_beg,subrs_sofar,subrs_end,O,Q,S,T)
}

function prepare_list(n,C,F,N,P,  i,p) {
  # N, P -- doubly linked list of elements belonging to multi-element classes
  #         (N -- next; P -- previous)
  p=0; for (i=1; i<=n; i++) if (F[C[i]]>1) {N[p]=i; P[i]=p; p=i}; N[p]=0
  return n
}

function next_step(n,C,F,N,P,  T,G,i) {
  for (i=N[0]; i!=0; i=N[i]) {
    j=C[i]; k=C[i+1]
    if ((j,k) in T) {C[i]=T[j,k]; G[C[i]]++} else {C[i]=T[j,k]=i; G[i]=1}
  }
  for (i in G) if ((F[i]=G[i])==1) {# one-element class -- to be skipped
    N[P[i]]=N[i]; P[N[i]]=P[i]
  }
}

function find_subrs(r,R,O,Q,S, F,i,j,a,b,f) {
  for (i=r; i>=LEV; --i) {
    delta=i-1; for (j in F) delete F[j]
    for (j=R[i-1]+1; j<=R[i]; ++j) {
      a=R[j,0]
      if (!(a in O) && !((a+delta) in O)) {
        b=R[j,1]
        if (b in F) {
          f=F[b]
          if (f<0) fix_pool(a,delta,-f,O,Q)
          else
            if ((a-f>delta) && !(f in O) && !((f+delta) in O)) {
              S[++S[0]]=f; F[b]=-S[0]
              fix_pool(f,delta,S[0],O,Q)
              fix_pool(a,delta,S[0],O,Q)
            } else F[b]=a
        } else F[b]=a
      }
    }
  }
}

function output_classes(r,n,C,F,L,N,R, i,k) {
  for (i=N[0]; i!=0; i=N[i]) {
    k++; if (r>=LEV) {R[++R[0],0]=L[i];  R[R[0],1]=L[C[i]]}
  }
  if (r>=LEV) R[r]=R[0]
  return k
}

function fix_pool(b,d,s,O,Q, i) {for (i=b; i<=b+d; i++) O[i]=s; Q[b]=d}

function flush_font(sb,ssf,se,O,Q,S,T, i) {
  for (i=1; i<se; ++i) {
    if (i==sb) sub(ssf, ssf+S[0], T[i])
    output_line(T[i])
  }
  flush_subr_defs(ssf,Q,S,T)
  for (i=se; i<=T[0]; ++i)
    if (i in Q) i=output_subr_call(i,ssf,O,Q)
    else output_line(T[i])
}

function flush_subr_defs(ssf,Q,S,T, i,j,b) {
  for (i=1; i<=S[0]; ++i) {
    output_line("dup " ssf+i-1 " {")
    b=S[i]; for (j=b; j<=b+Q[b]; ++j) output_line(T[j])
    output_line("\treturn")
    output_line("\t} NP")
  }
}

function output_subr_call(i,ssf,O,Q) {
  output_line("\t" ssf+O[i]-1 " callsubr")
  return i+Q[i]
}

function ini_chstr() {
  chstr["rmoveto"]; chstr["hmoveto"]; chstr["vmoveto"]
  chstr["rlineto"]; chstr["hlineto"]; chstr["vlineto"]
  chstr["rrcurveto"]; chstr["hvcurveto"]; chstr["vhcurveto"]
  chstr["hstem"]; chstr["vstem"]; chstr["hstem3"]; chstr["vstem3"]
  chstr["closepath"];
#  chstr["callsubr"]; chstr["pop"]; chstr["callothersubr"]; chstr["dotsection"]
}

function output_line(t) {print t}

function mess(s) {print s  > CONSOLE; if (LOG!="") print s > LOG}
function messf(s) {printf s  > CONSOLE; if (LOG!="") printf s > LOG}

function verbose_mess(l,s) {
  if (VERBOSE>l) print s  > CONSOLE
  else if (VERBOSE==l) printf "." > CONSOLE
  if (LOG!="") print s > LOG
}
function verbose_messf(l,s) {
  if (VERBOSE>l) printf s  > CONSOLE
  else if (VERBOSE==l) printf "." > CONSOLE
  if (LOG!="") printf s > LOG
}
