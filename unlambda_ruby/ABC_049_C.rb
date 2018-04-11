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


ss = 0
cs = 'edrasm'

tf = [
	{'e': 2, 'd': 10},
	{'e': 2, 'd': 10},
	{'r': 3},
	{'a': 4},
	{'s': 5},
	{'e': 6},
	{'e': 2, 'd': 10, 'r': 1}, #6
	{'e': 2, 'd': 10, 'a': 4},
	{'r': 7},
	{'e': 8, 'd': 10},
	{'r': 11}, #10
	{'e': 12},
	{'a': 13},
	{'m': 9}, #13
	{}
]

sn = tf.length
$ngs = sn-1

oks = [1,6,7,9]






$heads = (0...sn).map {|i| (i+'a'.ord).chr + '. ' }.join('')

def ts(x)
	'(' + $heads + (x+'a'.ord).chr + ')'
end

$start = s2lam(ts(ss))

def tf2cs(tf,c)
	'(r ' + tf.map {|v| '(' + (if v[c.to_sym] then ts(v[c.to_sym]) else ts($ngs) end) + ')'}.join(' ') + ')'
end

$trans = s2lam(
	'(r. i. ' + 
#		(cs.chars.map {|c| '((x. ($iv2tf x) ' + tf2cs(tf,c) }.join("\n")) +
#		(cs.chars.map {|c| '((x. ($iv2tf x) ' + '(D ' + tf2cs(tf,c) + ')' }.join("\n")) +
#		(cs.chars.map {|c| '(D ((x. ($iv2tf x) ' + tf2cs(tf,c) }.join("\n")) +
		(cs.chars.map {|c| '(D (((x. ($iv2tf x) ' + tf2cs(tf,c) }.join("\n")) +
			' V ' + 
		(cs.reverse.chars.map {|c| ') (?%c i))) ) ' % c}.join("\n")) +
	')'
)

#p $trans.show

$flush = s2lam(
	'p. p ' + (0...sn).map{|x| if oks.include?(x) then "$t" else "$f" end}.join(' ')
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






p la.show
p la.reduce.show
p la.ski.ski_show.length
print la.ski.ski_show + "\n"

"""
for i in 0...sn do
	p i
	p s2lam(ts(i)).ski.ski_show
	p s2lam(ts(i)).ski.ski_show.length
end

p s2lam('a. K (K (K a))').ski.ski_show
"""

