require './interp.rb'

#はじめてのatcoder A 
la = s2lam('''
	K ((ri. $print_int ($add (ri *0) ($add (ri *0) (ri *0)))) $read_int) 
		(.g I) (Z (f. i. @ (x. | x f i)) I)
''')

p la.ski.ski_show
