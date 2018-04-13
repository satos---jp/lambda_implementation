
#p s2lam('a. b. a').ski.ski_show
#p s2lam('a. b. b').ski.ski_show
#p s2lam('a. b. b').ski.reduce.ski_show

#p $zcon.show

la = s2lam('@ C c.(K .a (?1 c .b))')
la = s2lam('@ ?1')
la = s2lam('$to_c *6')
#p la.show
#la = s2lam('$to_c *1')
#p la.ski.ski_show


"""
for i in 0..5 do
	for j in 1..5 do
		#s = '$isge *%d *%d .t .f' % [i,j]
		s = '$divmod *%d *%d (a. b. S ($to_c a) ($to_c b))' % [i,j]
		p s
		p s2lam(s).reduce.show
	end
	p ''
end
"""


la = s2lam('$to_c ($add *3 *2)')

#la = s2lam('$iszero *32')


la = s2lam('$divmod *5 *2 (a. b. S ($to_c a) ($to_c b))')

#la = s2lam('$isge V *0 .t .f')

#la = s2lam('K I (C (c. c)) (C (c. c))')

la = s2lam('$print_int ($read_int I)')

la = s2lam('$print_int *30')

la = s2lam('$print_int ($read_int *0)')

la = s2lam('(ri. $print_int ($add (ri *0) (ri *0))) $read_int')

la = s2lam('K ((ri. $print_int ($add (ri *0) ($add (ri *0) (ri *0)))) $read_int) ')


la = s2lam('Z (f. i. @ (x. | x f i)) I')




s2lam('K I').reduce


#la = s2lam('(ri. $print_int ($add (ri *0) (ri *0))) $read_int')


#la = s2lam('($iv2tf (@ ?1))')


#la = s2lam('$to_c (@ $isdigit)')

#la = s2lam('@ (i.(x. ($iv2tf x) .t .f)) (?0 i))')

"""
p la.show
p la.reduce.show
p la.ski.ski_show.length
p la.ski.ski_show
"""

p s2lam('$read_int').ski.ski_show

#p s2lam('$print_int').ski.ski_show.length
#p s2lam('$read_int').ski.ski_show.length


#p la.ski.ski_show
#.ski.ski_show

#print s2lam('$to_c').ski.ski_show


