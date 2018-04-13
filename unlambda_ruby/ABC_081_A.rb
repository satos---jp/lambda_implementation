require './interp.rb'

#Placing Marbles
la = s2lam('''
	(a. b. c. a
		(b 
			(c .3 .2)
			(c .2 .1)
		)
		(b 
			(c .2 .1)
			(c .1 .0)
		)) ($iv2tf (@ ?1)) ($iv2tf (@ ?1)) ($iv2tf (@ ?1)) I
''')


