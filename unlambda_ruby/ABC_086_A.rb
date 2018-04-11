require './interp.rb'

# Product
$iseven = s2lam('n. n (a. b. $not a)')
la = s2lam('''
	(ri. z. ($iseven (ri z)) $t ($iseven (ri z)) (i. i .E .v .e .n) (i. i .O .d .d) I I)
	$read_int *0
''')


p la.show
p la.reduce.show
p la.ski.ski_show.length
p la.ski.ski_show


