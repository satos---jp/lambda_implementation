class ContErr < StandardError;
	def initialize(tag,v)
		@t = tag
		@v = v
	end
	def v; @v end
	def tag; @t end
end


class Cont
	def initialize(c)
		@c = c
	end
	def show(_=false)
		'<cont %d>' % @c
	end
	def c
		@c
	end
	def subst(v,t)
		self
	end
	def reduce
		self
	end
	def isfree(v)
		false
	end
end 

class Com
	def initialize(v)
		@v = v
	end
	def show(_=false)
		@v
	end
	def v 
		@v
	end
	def ski
		if @v == 'Z' then
			$zcon.ski		
			#self
		else
			self
		end
	end
	def ski_show
		@v.downcase
	end
	def subst(v,t)
		self
	end
	def reduce
		self
	end
	def isfree(v)
		false
	end
end

class Var
	def initialize(v)
		@v = v
	end
	def show(_=false)
		@v
	end
	def v
		@v
	end
	def ski
		self
	end
	def ski_show
		if @v[0] == "$" then
			eval(@v).ski.ski_show
		else
			@v
		end
	end
	def subst(v,t)
		if v == @v then t else self end
	end
	def reduce
		if @v[0] == "$" then
			eval(@v).reduce
		else
			self
		end
	end
	def isfree(v)
		v == @v
	end
end

class Abs
	def initialize(v,b)
		@v = v
		@b = b
	end	
	def v
		@v
	end	
	def b
		@b
	end
	def show(parent=true)
		res = 'λ' + @v + '.' + @b.show(false)
		if !parent then
			res = '(' + res + ')'
		end
		res
	end
	def ski
		#p 'show ' + self.show
		if (@b.is_a? Var) && @b.v == @v then
			res = Com.new('I')
		elsif !@b.isfree(@v) then
			res = App.new(Com.new('K'),@b.ski)
		elsif @b.is_a? Abs then
			res = Abs.new(@v,@b.ski).ski
		elsif @b.is_a? App then
			res = 
				App.new(App.new(
					Com.new('S'),
					Abs.new(@v,@b.fst).ski),
					Abs.new(@v,@b.snd).ski)
		else
			res = App.new(Com.new('K'),@b)
		end
		#p 'from ' + self.show + ' to ' + res.show
		res
	end
	def subst(v,t)
		if v == @v then self else 
			Abs.new(@v,@b.subst(v,t))
		end
	end
	def reduce
		#Abs.new(@v,@b.reduce)
		self
	end
	def isfree(v)
		if v == @v then false else @b.isfree(v) end
	end
end

class App
	def initialize(a,b)
		@a = a
		@b = b
	end
	def show(parent = false)
		res = @a.show(false) + ' ' + @b.show(true)
		if parent then
			res = '(' + res + ')'
		end
		res
	end
	def fst
		@a
	end
	def snd
		@b
	end
	def ski
		App.new(@a.ski,@b.ski)
	end
	def ski_show
		'`' + @a.ski_show + @b.ski_show
	end
	
	def subst(v,t)
		App.new(@a.subst(v,t),@b.subst(v,t))
	end
	def reduce
		#p self.show
		a = @a.reduce
		if a.is_a? Abs then
			#p self.show
			#p "%s [ %s := %s ] reduce to %s" % [ a.b.show ,a.v ,@b.show ,a.b.subst(a.v,@b).show]
			return a.b.subst(a.v,@b).reduce
		end
		b = @b.reduce
		#b = @b
		
		def iscom(a,v)
			a.is_a?(Com) && a.v == v 
		end
		
		if iscom(a,'I') then
			return b
		elsif iscom(a,'V') then
			return a
		elsif iscom(a,'C') then
			if $contcnt then $contcnt += 1 else $contcnt = 0 end
			tag = $contcnt
			begin
				return App.new(b,Cont.new(tag)).reduce
			rescue ContErr => e
				if e.tag == tag then 
					return e.v
				else
					raise e
				end
			end
		elsif a.is_a? Cont then
			raise ContErr.new(a.c,b)
		#elsif iscom(a,'Y') then
		#	return App.new(b,App.new(Com.new('Y'),b))
		elsif a.is_a? App then
			if iscom(a.fst,'K') then
				return a.snd
			elsif iscom(a.fst,'Z') then
				return App.new(App.new(a.snd,a),b).reduce
			elsif a.fst.is_a? App then
				if iscom(a.fst.fst,'S') then
					#p App.new(App.new(App.new(a.fst.snd,b),a.snd),b)
					return App.new(App.new(a.fst.snd,b),App.new(a.snd,b)).reduce
				end
			end
		end
		return App.new(a,b)
	end
	def isfree(v)
		@a.isfree(v) || @b.isfree(v)
	end
end


def s2lam(s)
	s = '(' + s + ')'
	s = s.split.map{|x| x.split(/(\$\w+|\w+|\.\w|\.|->|\)|\(|\?\w|\*\d+,\d+|\*\d+|)/)}.flatten.select{|x| x != ""}
	def parse(x)
		#p x
		#p x[1]
		#p x[1] == "." || x[1] == '->'
		if x == [] then
			raise "failure"
		end
		
		def parse_apps(x)
			res = nil
			while x[0] != ')' do
				v,x = parse(x)
				res = if res then App.new(res,v) else v end
			end
			return res,x
		end
		
		if x[0] == '(' then
			#p 'App'
			x = x.drop(1)
			res,x = parse_apps(x)
			x = x.drop(1)
			return res,x
		elsif x[1] == "." || x[1] == "->" then
			#p 'Abs'
			v = x[0]
			bo,x = parse_apps(x.drop(2))
			return Abs.new(v,bo),x
		else
			v = 
				if x[0][0] == '*' then 
					if x[0].include? "," then
						vs = x[0].delete('*').split(",")
						n2lam(vs[0].to_i,vs[1].to_i)
					else
						n2lam x[0].delete('*').to_i 
					end
				elsif x[0][0].match(/[[:upper:]]/) then Com.new(x[0])
				else Var.new(x[0]) end
			return v,x.drop(1)
		end
	end
	#p s
	res,_ = parse(s)
	res
end



require './library.rb'



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


#はじめてのatcoder A 
la = s2lam('''
	K ((ri. $print_int ($add (ri *0) ($add (ri *0) (ri *0)))) $read_int) 
		(.g I) (Z (f. i. @ (x. | x f i)) I)
''')

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

#p s2lam('$print_int').ski.ski_show.length
#p s2lam('$read_int').ski.ski_show.length


#p la.ski.ski_show
#.ski.ski_show

#print s2lam('$to_c').ski.ski_show







