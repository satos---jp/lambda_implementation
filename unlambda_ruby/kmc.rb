require './interp.rb'

require './library.rb'

$iszero = s2lam('n. n (a. $f) $t')
$inc = s2lam('n. s. z. s (n s z)')
$l_0 = s2lam('s. z. z')
$makep = s2lam('x. y. p. p x y')
$fst = s2lam('p. p (x. y. x)')
$snd = s2lam('p. p (x. y. y)')
$dec = s2lam('n. $fst (n (p. $makep ($snd p) ($inc ($snd p))) ($makep $l_0 $l_0))')
$and = s2lam('k. u. k u $f')
$iseq = s2lam('n. m. $and ($iszero (n $dec m)) ($iszero (m $dec n))')

la = s2lam('''
  (ri. 
    (x. y.
      y .A .C 
      ($dec ($dec x))
        (z. z .A I (($dec ($dec y)) .B z) .A .C I) I 
      y .A I
    ) 
    ($bin2churchdo (ri *0)) ($bin2churchdo (ri *0))
  ) $read_int I I
''')


#la = s2lam('$checons')

#la = s2lam('($dec ($dec ($bin2churchdo *10))) .A .C')
#la = s2lam('($dec ($bin2churchdo *10)) K I')
print la.ski.simplify.ski_show

