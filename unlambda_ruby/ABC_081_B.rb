require './interp.rb'


#チャーチ数にする
$bin2church = s2lam('''
	(i. Z (f. n. 
		$checons n 
			(a. b. 
				(D (tb. s. z. tb s (tb s (a (s z)) z))))
				(i f I b)
			)
			(s. z. z)
	))
''')


$bin2churchdo = s2lam('''
	Z (f. n. s. z.
		$checons n 
			(a. b. 
				(tb. tb s (tb s (a (s z) z)))
				(f b)
			)
			z
	)
''')

$bin2churchdo = s2lam('''
	Z (f. n. s. z.
		C (c. K z (n (a. b. a I I) c (n (a. b. 
				(tb. tb s (tb s (a (s z) z)))
				(f b)
			))))
	)
''')


$bin2churchdo = s2lam('''
	Z (f. n. z. s.
		C (c. K z (V (s z)
		))
	)
''')


$bin2churchdo = s2lam('''
	Z (f. n. s. z.
		$checons n 
			(a. b. 
				(tb. tb s (tb s (a s I z))) (f b) 
			)
			z
	)
''')

#7 .. 70101 -> 95712 まぁ偉い。

$truncate_num = s2lam('''
	Z (f. n.
		n (a. b. ($iszero n) V ($cons a (f b)))
	)
''')

la = s2lam('''
	$bin2churchdo ($truncat_num *100) .x I 
''')


$min = s2lam('''
	n. m. ($isge n m) m n
''')

"""
$min = s2lam('''
	Z (f. n. m.
		$checons n (na. nb. 
			$checons m 	(ma. mb.
				(f nb mb) 
				(na 
					(ma I (K 
			)
			m
		)
		n
	)
''')
"""

$getketa = s2lam('''
	Z (f. n.
		n (a. b. a *0 ($inc (f b)))
	)
''')

la = s2lam('''
	(ri. tn. 
	$print_int (
		$bin2churchdo (tn *3)
			(r. $min ($getketa (ri (K *0 r))))) (tn *33)
	)) $read_int $truncat_num
''')

#Shift Only
la = s2lam('''
	$print_int (
		$bin2churchdo ($truncat_num *1)
			(r. $min ($getketa ($read_int (K *0 r))))) ($truncat_num *33)
	)
''')

la = s2lam('''
	$print_int (
			(r. $min ($getketa ($read_int (K *0 r))) r) ($truncat_num *33)
	)
''')


la = s2lam('''
	$print_zero_int (
			(r. $min *10 r) ($truncate_num *33)
	)
''')


la = s2lam('''
	$print_int (
		(r. $min ($getketa ($read_int (K *0 r))) r) ($truncate_num *33)
	)
''')

la = s2lam('''
	(ri. tn. 
	$print_int (
		$bin2churchdo ($cons $t V)
			(r. $min ($getketa (ri (K *0 r))) r) (tn *33)
	)) $read_int $truncate_num
''')


$print_zero_int = s2lam('''
	n. K I (($iszero n) .0 $print_int n)
''')

la = s2lam('''
	(ri. tn. 
	$print_zero_int (
		$bin2churchdo (tn (ri *0))
			(r. $min ($getketa (ri (K *0 r))) r) (tn *33)
	)) $read_int $truncate_num
''')




#200 * 5桁、が 4.4秒。 理論で 8秒はかかりそう...

#入力するだけで3.0 秒。出力を入れると 4.6 秒。 $truncate_num と max を毎回やると早い...か？


$getketa = s2lam('''
	Z (f. n.
		n (a. b. a *0,5 ($inc (f b)))
	)
''')

la = s2lam('''
	(ri. tn. 
	$print_zero_int (
		$bin2churchdo (tn (ri *0))
			(r. $min ($getketa (ri (K *0,3 r))) r) *31,5
	)) $read_int $truncate_num
''')


# truncateすると、 200 * 5桁、が 2.2秒
# 最大でも 4.08秒 になる。 が、... まだ1/2 にしないといけない... (入力がボトルネック)

# 1e9 * 200 で 3.3秒。 しぶい。

# 2 ** 29 .. 536870912 (このとき、答えは30)

# 23 .. ok 20 .. ng で、 20 の時点で 2.2 sec 23 で 2.6 sec

# extent すると 29 sec になった...

#ext2 で 2.2 sec で正解してくれる

# 0,2 だと WA, 0,3 だと TLE する...


#minをとると 2.1 sec min を とらないと 2.01 sec. 微妙に足りない。
la = s2lam('''
	(ri. 
	$print_zero_int (
		$bin2churchdo ($truncate_num (ri *0))
			(r. $min ($getketa (ri (K *0,3 r))) r) *31,5
	)) $read_int 
''')

#la = s2lam('''$print_zero_int ($read_int *0,0)''')

la = s2lam('''$print_zero_int ($read_int I)''')

la = s2lam('''
	(ri. 
	$print_zero_int (
		$bin2churchdo ($truncate_num (ri I))
			(r. $min ($getketa (ri (K I r))) r) *31,5
	)) $read_int 
''')

la = s2lam('''
	(ri. 
	$print_zero_int (
		$bin2churchdo ($truncate_num (ri *0))
			(r. $min ($getketa (ri (K *0,3 r))) r) *31,5
	)) $read_int 
''')

#p la.show
#p la.reduce.show
#p la.reduce.reduce.show
#p la.ski.ski_show.length
print la.ski.ski_show

