require './interp.rb'
require './library.rb'

$ischurchnum = true

$ycon = s2lam('f. (x. f (x x)) (x. f (x x))')
$pair = s2lam('a. b. p. p a b')
$t = s2lam('a. b. a')
$f = s2lam('a. b. b')
$fst = s2lam('p. p $t')
$snd = s2lam('p. p $f')
$inc = s2lam('n. s. z. s (n s z)')
$succ = $inc
$add = s2lam('n. m. n $inc m')
$pred = s2lam('n. $snd (n (p. $pair ($inc ($fst p)) ($fst p)) ($pair *0 *0))')
$sub = s2lam('n. m. m $pred n')
$iszero = s2lam('n. n (a. $f) $t')

# s2lam('l. ($pair *65 ($pair *256 *0))')
la = s2lam('''
	(sb. pd.
		$ycon (f. v. c. p. 
			p (a. b. 
				$iszero v (
					(n50. $pair a ($iszero (sb a n50) (f v *0 b) (f *1 n50 b))) *50
				) (
					$iszero (sb *75 a) (
						$pair a (f *2 (pd c) b)
					) (
						$iszero c (
								(n50. $pair n50 ($iszero (pd v) (f *1 n50 b) $t)) *50
						) (
							$pair ($iszero (pd v) a ($inc a)) (f v (pd c) b)
						)
					)
				)
			)
		) *0 *0
	) $sub $pred
''')


la = s2lam('''
	(sb. pd.
		$ycon (f. v. c. p. 
			p (a. b. 
				(n50. 
					$iszero v (
						$pair a ($iszero (sb a n50) (f v *0 b) (f *1 n50 b))
					) (
						$iszero (sb n50 a) (
							$pair a (f *2 (pd c) b)
						) (
							$iszero c (
									$pair n50 ($iszero (pd v) (f *1 n50 b) $t)
							) (
								$pair ($iszero (pd v) a ($inc a)) (f v (pd c) b)
							)
						)
					)
				) *50
			)
		) *0 *0
	) $sub $pred
''')

# 3167
la = s2lam('''
	(pd.
		$ycon (f. v. c. p. 
			p (a. b. 
				(n50. 
					(issban50. 
						$iszero v (
							$pair a (issban50 (f v *0 b) (f *1 n50 b))
						) (
							issban50 (
								$iszero c (
										$pair n50 ($iszero (pd v) (f *1 n50 b) $t)
								) (
									$pair ($iszero (pd v) a ($inc a)) (f v (pd c) b)
								)
							) (
								$pair a (f *2 (pd c) b)
							)
						)
					) ($iszero ($sub a n50))
				) *50 
			)
		) *0 *0
	)  $pred
''')

$isodd = s2lam('n. n (a. a $f $t) $f')

#print s2lam('$sub').ski.simplify.ski_show.size

# 2603
la = s2lam('''
		$ycon (f. v. c. p. 
			p (a. b. 
				(n50. 
					(issban50. 
						$iszero v (
							$pair a (issban50 (f v *0 b) (f *1 n50 b))
						) (
							(pdc. 
								issban50 (
									$iszero c (
											$pair n50 ($isodd v (f *1 n50 b) $t)
									) (
										$pair ($isodd v a n50) (f v pdc b)
									)
								) (
									$pair a (f *2 pdc b)
								)
							) ($pred c)
						)
					) ($iszero ($sub a n50))
				) ((n. s. z. n s (n s z)) (*2 *5))
			)
		) *0 *0
''')

$ismod30 = s2lam('n. n (d. d (a. b. c. b) (a. b. c. c) (a. b. c. a)) (a. b. c. a) $t $f $f')
# 2603
la = s2lam('''
		($ycon (f. g. p. 
			p (a. b. 
				($pair a (($ismod30 a) g (f g) b))
			)
		))
		(
			($ycon (f. g. i. p. 
				p (a. b. 
					$pair 
						(($iszero i) $succ (t. t) a) 
						(($isodd a) (g i) (f g (($iszero i) ((n. s. z. n s (n s z)) (*2 *5)) ($pred i))) b)
				)
			))
			(p. $t) *1
		)
''')

$ismod31 = s2lam('n. n (d. d (a. b. c. b) (a. b. c. c) (a. b. c. a)) (a. b. c. a) $f $t $f')

$and = s2lam('a. b. a b $f')

la = s2lam('''
		($ycon (f. g. t. p. 
			p (a. b. 
				($pair a (($ismod30 a) (g t) (f g ($succ t)) b))
			)
		) *0)
		(
			($ycon (f. g. i. j. p. 
				p (a. b. 
					$pair 
						(($and ($iszero ($sub i j)) ($iszero ($sub j i))) (t. t) a) 
						(($isodd a) (g i) (f g 
							(($ismod31 a) *0 ($succ i))
						j b))
				)
			))
			(p. $t) *0
		)
''')

$n50 =  s2lam('(n. s. z. n s (n s z)) (*2 *5)')

$trip =  s2lam('a. b. c. x. x a b c')
$trip1 =  s2lam('x. x (a. b. c. a)')
$trip2 =  s2lam('x. x (a. b. c. b)')
$trip3 =  s2lam('x. x (a. b. c. c)')


#foldr 

la = s2lam('''
		($ycon (f. g. p. 
			p (a. b. 
				($pair a (($ismod30 a) g (f g) b))
			)
		))
		(
			($ycon (f. p. 
				(q. ($trip2 q) ($trip1 q $t 
					(f ($trip3 q))
				))
				($n50 (r. ($trip3 r) (a. b. 
					($isodd a) 
						($trip $t (l. ($trip2 r) ($pair a l)) b)
						($trip ($trip1 r) (l. ($trip2 r) ($pair (($trip1 r) $succ (x. x) a) l)) b)
				)) ($trip $f (l. l) p))
			))
		)
''')

la = s2lam('''
		($ycon (f. g. p. 
			p (a. b. 
				($pair a (($ismod30 a) g (f g) b))
			)
		))
		(
			($ycon (f. p. 
				(q. ($trip2 q) ($trip1 q $t
					(($trip3 q) (a. b. ($pair ($succ a) (f b))))
				))
				($n50 (r. ($trip3 r) (a. b. 
					($isodd a) 
						($trip $t (l. ($trip2 r) ($pair a l)) b)
						($trip ($trip1 r) (l. ($trip2 r) ($pair (($trip1 r) $succ (x. x) a) l)) b)
				)) ($trip $f (l. l) p))
			))
		)
''')

la = s2lam('''
		($ycon (f. g. p. 
			p (a. b. 
				($pair a (($ismod30 a) g (f g) b))
			)
		))
		(
			($ycon (f. p. 
				(q. ($trip2 q) (($trip3 q) (a. b. ($pair ($succ a) (($trip1 q) $t (f b))))
				))
				($n50 (r. ($trip3 r) (a. b. 
					($isodd a) 
						($trip $t (l. ($trip2 r) ($pair a l)) b)
						($trip ($trip1 r) (l. ($trip2 r) ($pair (($trip1 r) $succ (x. x) a) l)) b)
				)) ($trip $f (l. l) p))
			))
		)
''')

#la = s2lam('l. ($pair ($trip2 ($trip *65 *66 *67)) ($pair *256 *0))')
#				(q. ($trip3 q))
#				($n50 (r. ($trip3 r) (a. b. 
#						($trip $t (l. ($trip2 r) ($pair a l)) b)
#				)) ($trip $f (l. l) p))

#				(q. ($trip2 q) ($trip1 q $t (f ($trip3 q))))
#					($isodd a) 
#						($trip ($trip1 r) (l. ($trip2 r) ($pair (($trip1 r) $succ (x. x) a) l)) b)



#print la.ski.simplify.ski_show.size

print la.ski.simplify.ski_show
