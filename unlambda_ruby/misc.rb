require './interp.rb'

#p ('a' .. 'z').to_a

#p not('hioge'.include? 'e')


la = s2lam('''
	(ri. $isge ($add (ri *0) (ri *0)) (ri *0) (i. i .Y .e .s) (i. i .N .o) I I) $read_int
''')

$min = s2lam('''
	n. m. ($isge n m) m n
''')

$binlength=11

la = s2lam('''
	(ri. $print_int ($add ($min (ri *0) (ri *0)) ($min (ri *0) (ri *0)))) $read_int
''')

la = s2lam('@ | I @ @ @ @ @ | I @ @ @ @ @ | I')

$binlength=11

$print_zero_int = s2lam('''
	n. K I (($iszero n) .0 $print_int n)
''')

la = s2lam('''
	$print_zero_int ($divmod ($read_int *0) *3 (a. b. a))
''')

$binlength=15

la = s2lam('''
	 (ri. $isg ($divmod (ri *0) *500 (a. b. b)) (ri *0) (i. i .N .o) (i. i .Y .e .s) I I) $read_int
''')

la = s2lam('.2 .0 .1 .8 .r .0 .1 .r @ @ @ @ @ @ @ @ @ | I @ | I')

$binlength=7

la = s2lam('$print_int ($sub *48 ($read_int *0))')

def s2putslam(s)
	'(i. i' + s.chars.map{|c| ' .%c' % c}.join('') + ')'
end

la = s2lam('''
	 (ri. $isg_eq ($add (ri *0) (ri *0)) ($add (ri *0) (ri *0)) 
	 	(a. b. a (x. y. z. x) (b (x. y. z. y) (x. y. z. z)))
''' + 
s2putslam('Left') + s2putslam('Balanced') + s2putslam('Right') + 
' I I) $read_int'
)

$binlength=9

la = s2lam('''
	 (ri. $print_int (($inc ($add (ri *0) (ri *0))) (a. b. b))) $read_int
''')

$binlength=32

$zerosub = s2lam('''
	x. y. $isge y x *0 ($sub x y)
''')


la = s2lam('''
	 (ri. 
	 	$print_zero_int ($zerosub (ri *0) (ri *0))
	 ) $read_int
''')

$max = s2lam('''
	n. m. ($isge n m) n m
''')


$diffabs = s2lam('''
	a. b. $max ($zerosub a b) ($zerosub b a) 
''')

la = s2lam('''
	 (ri. 
	 	(x. a. b. 
	 		$isge ($diffabs x a) ($diffabs x b) .B .A I
	 	) (ri *0) (ri *0) (ri *0)
	 ) $read_int
''')

la = s2lam('.A .B .C @ | I @ | I @ | I')

$binlength=9

$mod3_zero = s2lam('''
	n. ($iszero ($divmod n *3 (a. b. b)))
''')

la = s2lam('''
	 (ri. mz.
	 	(a. b. 
	$or (mz a) ($or (mz b) (mz ($add a b)))
''' +
s2putslam('Possible') + s2putslam('Impossible') +
'''
	 	I I) (ri *0) (ri *0)
	 ) $read_int $mod3_zero
''')

$binlength=16

la = s2lam('''
	 (ri.
	 	(a. b. c. 
	 		$print_int ($sub ($add ($add a b) c) ($max a ($max b c)))
	 	) (ri *0) (ri *0) (ri *0)
	 ) $read_int
''')

la = s2lam('''
	 (ri.
	 	(x. a. b.
	 		$print_zero_int ($divmod ($sub x a) b (x. y. y))
	 	) (ri *0) (ri *0) (ri *0)
	 ) $read_int
''')

$binlength=33

la = s2lam('''
	 (ri. $isg_eq ($add (ri *0) (ri *0)) ($inc (ri *0))
	 	(a. b. a (x. y. z. x) (b (x. y. z. y) (x. y. z. z)))
''' + 
s2putslam('delicious') + s2putslam('safe') + s2putslam('dangerous') + 
' I I) $read_int'
)

la = s2lam('''
	 (ri.
	 	(a. b. c. 
	 		($iszero ($diffabs ($add a c) ($cons $f b)))
''' + 
s2putslam('YES') + s2putslam('NO') + 
'''
	 	I I ) (ri *0) (ri *0) (ri *0)
	 ) $read_int
''')

$binlength=7


la = s2lam('''
	 (ri.
	 	(a. b.
	 		$print_zero_int ($divmod ($add a b) *24 (x. y. y))
	 	) (ri *0) (ri *0)
	 ) $read_int
''')

$binlength=13

la = s2lam('''
	 (ri.
	 	(x.
	 		($isge x *1200)
''' + 
s2putslam('ARC') + s2putslam('ABC') + 
'''
	 	I I ) (ri *0)
	 ) $read_int
''')

$binlength=9

la = s2lam('''
	 (ri.
	 	(x. y. 
	 		($isge y x)
''' + 
s2putslam('Better') + s2putslam('Worse') + 
'''
	 	I I ) (ri *0) (ri *0)
	 ) $read_int
''')





print la.ski.simplify.ski_show

