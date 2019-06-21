s = input()
#print(len(s))

import sys
sys.setrecursionlimit(100000)


def parse(s):
	def f(x):
		if x[0]=='`':
			x = x[1:]
			p,x = f(x)
			q,x = f(x)
			return (p,q),x
		else:
			return x[0],x[1:]
	
	res,rem = f(s)
	assert rem == ""
	return res
	
s = parse(s)

# (A B) (C D)  -> A B (C D)

def simplify(x):
	res = []
	while type(x) is tuple:
		res.append(simplify(x[1]))
		x = x[0]
	if len(res)==0:
		return x
	elif len(res)==1:
		return '`%s%s' % (x,res[0])
	else:
		return '(%s%s)' % (x,''.join(res[::-1]))

s = simplify(s)
#print(len(s))
print(s)
	
