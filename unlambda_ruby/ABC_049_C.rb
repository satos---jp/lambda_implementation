require './interp.rb'


#daydream
#read int を応用する



$start = s2lam('x. y. x')

$trans = s2lam('''
	(r. i. 
		((x. ($iv2tf x) (r (x. y. y) (x. y. x))
			V
		) (?a i))
	)
''')

$flush = s2lam('''
	p. p $t $f
''')

$checf = s2lam('''
	n. f. v. 
		C (c. K v (n I I c (D (f n))))
''')

# aが偶数


cs = 'eramsd'

#lws = ('a' .. 'z').to_a.select{|x| not(cs.include? x)}
lws = []





# 9 <-> 12, 1 <-> 11
ss = 0
tf = [
	{'e': 11, 'd': 12},
	{'a': 9}, #1
	{'a': 3},
	{'s': 4},
	{'e': 5},
	{'e': 11, 'd': 12, 'r': 0}, #5
	{'e': 11, 'd': 12, 'a': 3},
	{'r': 6},
	{'e': 7, 'd': 12},
	{'m': 8}, #9
	{'e': 1},
	{'r': 2}, #11
	{'r': 10} #12
]
oks = [0,5,6,8]


ss = 0
tf = [
	{'e': 1, 'd': 9},
	{'r': 2},
	{'a': 3},
	{'s': 4},
	{'e': 5},
	{'e': 1, 'd': 9, 'r': 0}, #5
	{'e': 1, 'd': 9, 'a': 3},
	{'r': 6},
	{'e': 7, 'd': 9},
	{'r': 10}, #9
	{'e': 11},
	{'a': 12},
	{'m': 8} #12
]
oks = [0,5,6,8]


sn = tf.length
$ngs = sn


"""
cs = 'ab'
tf = [
	{'a': 0, 'b': 1}, #0
	{'a': 0, 'b': 1}, #1
	{} #2
]
lws = ('a' .. 'c').to_a.select{|x| not(cs.include? x)}
"""






$heads = (0...sn).map {|i| (i+'a'.ord).chr + '. ' }.join('')

def ts(x)
	if x == $ngs then
		'(x. K I x .N .O E I)'
		#'(' + $heads + (0+'a'.ord).chr + ')'
	else
		'(' + $heads + (x+'a'.ord).chr + ')'
	end
end

$start = s2lam(ts(ss))

def tf2cs(tf,c)
	'(r ' + tf.map {|v| '(' + (if v[c.to_sym] then ts(v[c.to_sym]) else ts($ngs) end) + ')'}.join(' ') + ')'
end

$trans = s2lam(
	'(r. i. ' + 
		(cs.chars.map {|c| '((x. ($iv2tf x) ' + tf2cs(tf,c) }.join("\n")) +
#		(cs.chars.map {|c| '((x. ($iv2tf x) ' + '(D ' + tf2cs(tf,c) + ')' }.join("\n")) +
#		(cs.chars.map {|c| '(D ((x. ($iv2tf x) ' + tf2cs(tf,c) }.join("\n")) +
#		(cs.chars.map {|c| '(D (((x. ($iv2tf x) ' + tf2cs(tf,c) }.join("\n")) +
		(lws.map {|_| '((x. ($iv2tf x) ' + ts($ngs) }.join("\n")) +
			' V ' + 
		(lws.map {|c| ') (?%c i)) ' % c}.join("\n")) +
		(cs.reverse.chars.map {|c| ') (?%c i)) ' % c}.join("\n")) +
	')'
)

$trans = s2lam(
	'(r. i. C (c. ' + 
		(cs.chars.map {|c| '(?%c i c '% c + tf2cs(tf,c) + ')'}.join("\n")) +
		(lws.map {|c| '(?%c i c ' % c + ts($ngs) + ')' }.join("\n")) +
	'))'
)

#2.7 sec. まだだめ。

"""
for c in cs.chars do
	p c + ' ' + s2lam(tf2cs(tf,c)).ski.ski_show.length.to_s
end
"""

#print $trans.show

$flush = s2lam(
	'p. p ' + (0...sn).map{|x| if oks.include?(x) then "$t" else "$f" end}.join(' ')
)


$flush_char = s2lam(
	'p. p ' + (0...sn).map{|x| '.' + (x+'A'.ord).chr }.join(' ')
)

#p $flush.show

$checf = s2lam('''
	n. f. v. 
		C (c. K v (n 
''' + (0...sn).map{|x| ' I'}.join('') + 
' c (D (f n))))')




#p $checf.show



la = s2lam('''
	$flush 
		(Z (f. r.
			@ (i. 
				$checf ($trans r i) f r
			)
		) $start)
	(i. i .Y .E .S) (i. i .N .O) I I
''')

print la.ski.ski_show
exit


la = s2lam('''
	Z (f. r.
		@ (i. f (i C (c. 
''' + 
		(cs.chars.map {|c| '(?%c i c '% c + tf2cs(tf,c) + ')'}.join("\n")) +
		(lws.map {|c| '(?%c i .N .O E I)' % c }.join("\n")) +
		'(K I c $flush r (i. i .Y .E .S) (i. i .N .O) I I E I)' +
'''
		)))
	) $start
''')


"""
la = s2lam('''
	(Z (f. r. 
		@ (i. f (i C (c. (?x i c r) (?y i .N .O e I) (K I c e I))))
	)) I
''')
"""


# a-zでないと、 364 sec になる。

#p la.show
#p la.reduce.show
#p la.ski.ski_show.length

#la = s2lam('@ (i. $trans ' + ts(1) + ') I I ')

print la.ski.simplify.ski_show

"""
for i in 0...sn do
	p i
	p s2lam(ts(i)).ski.ski_show
	p s2lam(ts(i)).ski.ski_show.length
end

p s2lam('a. K (K (K a))').ski.ski_show
"""

