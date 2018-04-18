class ContErr < StandardError;
	attr_reader :v , :tag
	def initialize(tag,v)
		@tag = tag
		@v = v
	end
end

class Lam
	def reduce
		self
	end
	def subst(v,t)
		self
	end
	def isfree(v)
		false
	end
	def size
		1
	end
	def simplify
		self
	end
end

class Cont < Lam
	attr_reader :c
	def initialize(c)
		@c = c
	end
	def show(_=false)
		'<cont %d>' % @c 
	end
end

class Com < Lam
	attr_reader :v
	def initialize(v)
		@v = v
	end
	def show(_=false)
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
end

class Var
	attr_reader :v
	def initialize(v)
		@v = v
	end
	def show(_=false)
		@v
	end
	def ski
		if @v[0] == "$" then
			eval(@v).ski
		else
			self
		end
	end
	def ski_show
		@v
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
	def size
		1
	end
	def simplify
		self
	end
end

class Abs
	attr_reader :v , :b
	def initialize(v,b)
		@v = v
		@b = b
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
		self
	end
	def isfree(v)
		if v == @v then false else @b.isfree(v) end
	end
end

class App
	attr_reader :fst , :snd
	def initialize(a,b)
		@fst = a
		@snd = b
	end
	def show(parent = false)
		res = @fst.show(false) + ' ' + @snd.show(true)
		if parent then
			res = '(' + res + ')'
		end
		res
	end
	def ski
		App.new(@fst.ski,@snd.ski)
	end
	def ski_show
		'`' + @fst.ski_show + @snd.ski_show
	end
	
	def subst(v,t)
		App.new(@fst.subst(v,t),@snd.subst(v,t))
	end
	def reduce
		#p self.show
		a = @fst.reduce
		if a.is_a? Abs then
			#p self.show
			#p "%s [ %s := %s ] reduce to %s" % [ a.b.show ,a.v ,@snd.show ,a.b.subst(a.v,@snd).show]
			return a.b.subst(a.v,@snd).reduce
		end
		b = @snd.reduce
		#b = @snd
		
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
		@fst.isfree(v) || @snd.isfree(v)
	end
	
	def size
		@fst.size + @snd.size
	end
	def simplify
		ts = nil
		if self.size < 5
			if iscom(App.new(App.new(self,Com.new('X')),Com.new('Y')).reduce,'X') then
				#p self.show
				ts = Com.new('K')
			elsif iscom(App.new(self,Com.new('X')).reduce,'X') then
				ts = Com.new('I')
			#elsif self.reduce.size < self.size then
			#	ts = self.reduce
			end
		end
		if ts then
			ts
		else
			App.new(@fst.simplify,@snd.simplify)
		end
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








