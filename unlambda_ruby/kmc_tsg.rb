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

$false = s2lam('a. b. b')
$true = s2lam('a. b. a')
n = 50
$n50 = s2lam('s. z. ' + 's (' * n + ' z' + ')'*n)

la = s2lam('''
 ((
	 (Z (f. r. 
	 		(g. (x. I) g @ (i. .T g))
	 		(
		 		(x. x I ((D ( ( (f x)))))) 
		 		($n50 
		 			(q. K I q @ (i. 
			 			(p. p .X ((i ?U $iv2tf) .U .L) p) (
			 				(i ?K $iv2tf) $true q
			 			)
		 			)) 
		 			r
		 		)
		 	)
	 ))
	 (.T
		 (
			 (x. x $false)
			 (Z (f. r. 
				 	r @ (i.
				 		(i ?T $iv2tf) 
				 		I
				 		((D (f .A)))
				 	)
				) I I)
			)
		)
 ) I I)
''')



#                              T                   
#                             T                   
#                                T                   


#la = s2lam('$checons')

#la = s2lam('($dec ($dec ($bin2churchdo *10))) .A .C')
#la = s2lam('($dec ($bin2churchdo *10)) K I')
print la.ski.simplify.ski_show

