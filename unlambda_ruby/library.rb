#2進数で実装したほうがいいらしい
#32bit固定のほうが楽らしい
#true,false の組でやって、末尾をvにする

def n2lam(n,bl=$binlength)
	#s = 's. z.' + '(s' * n + ' z' + ')' * n
	def rec(n,d,bl)
		if d == bl then 'V' 
		elsif n % 2 > 0 then 
			'($cons $t ' + rec(n/2,d+1,bl) + ')'
		else
			'($cons $f ' + rec(n/2,d+1,bl) + ')'
		end
	end
	s2lam(rec(n,0,bl)) 
end

$binlength = 32

#p s2lam('x . x').show
#p s2lam('x . x').ski.ski_show

#p n2lam(3).show
#p n2lam(3).ski.ski_show

$t = s2lam('a. b. a')

$t = s2lam('K')
$f = s2lam('a. b. b')
$cons = s2lam('a. b. f. f a b')


#一文字の数字に変換する

$to_c = s2lam('''
	p.(p (a0. a1. (a0
		(a1 (b0. b1. (b0
			(b1 (c0. c1. (c0
				.7 .3
			)))
			(b1 (c0. c1. (c0
				.5
				(c1 (d0. d1. (d0
					.9 .1
				)))
			)))
		)))
		(a1 (b0. b1. (b0
			(b1 (c0. c1. (c0
				.6 .2
			)))
			(b1 (c0. c1. (c0
				.4
				(c1 (d0. d1. (d0
					.8 .0
				)))
			)))
		)))
	)))
''')

"""
$zcon = s2lam('''
	f.(x. f (y. (x x) y)) (x. f (y. (x x) y))
''')
$ycon = s2lam('''
	f.(x. f (x x)) (x. f (x x))
''')
"""

$zcon = s2lam('''
	f.(x. f (D (x x))) (x. f (D (x x)))
''')

$zcon = s2lam('''
	f.(x. f (D (x x))) (x. f (D (x x)))
''')

$zcon = s2lam('''
	S (S (S (K S) K) (K (S (K D) (S I I)))) (S (S (K S) K) (K (S (K D) (S I I))))
''')


#p $zcon.ski.ski_show
#p $zcon.ski.show

#exit

$numnot = s2lam('''
	Z (f. n.
		n (a. b. 
			((a ($cons $f) ($cons $t)) (f b))
		)
	)
''')

$numand = s2lam('''
	Z (f. n. m.
		n (a. b. 
			m (c. d. 
				((a ($cons c) ($cons $f)) (f b d))
			)
		)
	)
''')


$xor3 = s2lam('''
	a. b. c. a
		(b 
			(c $t $f)
			(c $f $t)
		)
		(b 
			(c $f $t)
			(c $t $f)
		)
''')

$ge2 = s2lam('''
	a. b. c. a
		(b 
			(c $t $t)
			(c $t $f)
		)
		(b 
			(c $t $f)
			(c $f $f)
		)
''')


$add = s2lam('''
	Z (f. r. n. m. 
		n (na. nb. 
			m (ma. mb. 
				$cons 
					($xor3 r na ma) 
					(f ($ge2 r na ma) nb mb)
			)
		)
	) $f
''')

$not = s2lam('f. f $f $t')


$sub = s2lam('''
	Z (f. r. n. m. 
		n (na. nb. 
			m (ma. mb. 
				$cons 
					($xor3 r na ($not ma)) 
					(f ($ge2 r na ($not ma)) nb mb)
			)
		)
	) $t
''')

#contを使って、VとIを区別するやつ
$checons = s2lam('''
	n. f. v. 
		C (c. K v (n (a. b. a I I) c (n f)))
''')

$iszero = s2lam('''
	Z (f. n.
		$checons n
			(a. b. a $f (f b))
			$t
	)
''')

# n>m か n=>m かの組をかえす
$isge_eq = s2lam('''
	Z (f. n. m.
		$checons n 
			(na. nb. 
				$checons m 
					(ma. mb.
							(f nb mb) 
								(x. y. f. 
									(na 
										(ma
											(f x y)
											(f y y)
										)
										(ma
											(f x x)
											(f x y)
										)
									)
								)	
					)
					(f. f ($not ($iszero n)) $t)
			)
			(f. f $f ($iszero m))
	)
''')

$isge = s2lam('n. m. ($isge_eq n m) (a. b. a $t b)') 

# n/m と n % m をまとめてかえす
$divmod = s2lam('''
	gn. m. 
	Z (f. n.  
		$checons n 
			(na. nb. 
				(f nb) (ra. rb. 
					(tb.
						($isge tb m)
							(f. f ($cons $t ra) ($sub tb m))
							(f. f ($cons $f ra) tb)
					) ($cons na rb)
				)
			)
			(f. f V V)
	) gn
''')


$print_int = s2lam('''
	n. 
	(Z (f. n. 
		($iszero n) 
			I
			(D (($divmod n *10) (a. b. (f a) $to_c b)))
	)) n I
''')

$multten = s2lam('''
	n. $cons $f ($add n ($cons $f ($cons $f n)))
''')


$ext3 = s2lam('''
	Z (f. n.
		$checons n
			(a. b. ($cons a (f b)))
			($cons $f ($cons $f ($cons $f V)))
	)
''')

$ext2 = s2lam('''
	Z (f. n.
		$checons n
			(a. b. ($cons a (D (f b))))
			($cons $f ($cons $f V))
	)
''')



#ext2 を遅延させると Case 7 は通るようになる。
# 200 * 2 ** 29 が 2290 ms かかる。(Dなしでもほぼ差なし)



$ext1 = s2lam('''
	Z (f. n.
		$checons n
			(a. b. ($cons a (f b)))
			($cons $f V)
	)
''')

$multten = s2lam('''
	n. f. f $f ($add ($ext2 n) (f. f $f (f. f $f n)))
''')

$iv2tf = s2lam('''
	x. C (c. K $f (x c $t))
''')



$inc = s2lam('''
	Z (f. n. 
		n (na. nb. 
			na 
				($cons $f (D (f nb))) 
				($cons $t nb)
		)
	)
''')
# D を加えると、TLEに対してちょっと早くなった。

#@ (i.(x. ($iv2tf x) .t .f)) (?0 i))

$isdigit = s2lam('''
	(z. i. 
		((x. ($iv2tf x) z ($inc 
		((x. ($iv2tf x) z ($inc 
		((x. ($iv2tf x) z ($inc 
		((x. ($iv2tf x) z ($inc 
		((x. ($iv2tf x) z ($inc 
		((x. ($iv2tf x) z ($inc 
		((x. ($iv2tf x) z ($inc 
		((x. ($iv2tf x) z ($inc 
		((x. ($iv2tf x) z ($inc 
		((x. ($iv2tf x) z ($inc 
			v
		)) (?9 i))
		)) (?8 i))
		)) (?7 i))
		)) (?6 i))
		)) (?5 i))
		)) (?4 i))
		)) (?3 i))
		)) (?2 i))
		)) (?1 i))
		)) (?0 i))
	) *0
''')


$isdigit = s2lam('''
	(i. 
		(i ?0 $iv2tf) *0,28 (
		(i ?1 $iv2tf) *1,27 (
		(i ?2 $iv2tf) *2,30 (
		(i ?3 $iv2tf) *3,27 (
		(i ?4 $iv2tf) *4,28 (
		(i ?5 $iv2tf) *5,27 (
		(i ?6 $iv2tf) *6,29 (
		(i ?7 $iv2tf) *7,27 (
		(i ?8 $iv2tf) *8,29 (
		(i ?9 $iv2tf) *9,27 (
			V
		))))))))))
	)
''')

"""
$inc_kuri = s2lam('''
	Z (f. n. 
		$checons n (na. nb. 
			na
				($cons $f (f nb))
				($cons $t nb)
		) ($cons $t V)
	)
''')


$add = s2lam('''
	Z (f. r. n. m. 
		$checons n (na. nb. 
			$checons m (ma. mb. 
				$cons 
					($xor3 r na ma) 
					(f ($ge2 r na ma) nb mb)
			)  (r ($inc_kuri n) n)
		) (r ($inc_kuri m) m)
	) $f
''')
"""


$read_int = s2lam('''
	Z (f. r.
		@ (i. 
			$checons ($isdigit i) 
				(a. b. f ($add ($cons a b) ($multten r)))
				r
		)
	)
''')

#12



$read_int = s2lam('''
	i. (id. 
	(Z (f. r.
		@ (i. 
			$checons (id i) 
				(a. b. f ($add ($cons a b) ($multten r)))
				r
		)
	) (i @ id))) (i $isdigit)
''') #print "200 " + "123456789 " * 200 で 2848ms になる...


$read_int = s2lam('''
	Z (f. r.
		@ (i. 
			$checons ($isdigit i) 
				(a. b. f ($add ($cons a b) ($multten r)))
				r
		)
	)
''') #print "200 " + "123456789 " * 200 で 2051ms 。なぜかこっちの方が早い。


