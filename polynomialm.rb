# PolynomialM : polynomial class of multi variable
# Monomial : monomial class of multi variable
#
############################################
# by toyofuku@juice.or.jp, 3 Feb 2000
#   Idea of "P_.x"
# K.Kodama(kodama@kobe-kosen.ac.jp) 2000-01-30
#   first(experimental) version
#
# This module is distributed freely in the sence of 
# GPL(GNU General Public License).
############################################
#
# class PolynomialM
#
# ARITHMETIC:
# +, -, *, /, %, 
# **(n)
#      "n" be Integer
# divmod(divisors)
#      divisors be Array of PolynomialM
#      return q,r
#      quotient q is Array of PolynomialM  [q1, q2,...,qn]
#      residue r is Polynomial
# divmodZp(divisors)
#      divide in Zp
# divmodI(divisors)
#      divide in Z
#      quotient は Integer係数で得ます. 
#      係数の丸めは leading term の剰余が非負になる方向に行います.
# substitute(list) # list is Hash of "var"=>val
#     value admit Integer, Rational, Float, Polynomial, PolynomialM....
#     代入は現在の式に対して一気に行います.
#     例えば:
#     f1=PolynomialM("x+y^2")
#     f2=f1.substitute("x"=>PolynomialM("y"),"y"=>PolynomialM("x"))
#     で x, y が入れ替わり x^2+y を得ます.
# derivative(vars) # vars is Array of var names
#    derivative
#    先頭の変数から順に偏微分します.
#    f.derivative(["x","x","y"])
# integral(vars)  # vars is Array of var names
#     integral
#    先頭の変数から順に積分し原始関数を求めます.
#    積分定数は考慮しません.
# lt      leading term
# lc      leading coefficient
# lp      leading power product
# coeff(var,deg) # var の多項式と見ての deg 次の係数多項式を返す.
# maxdeg(var) # var の多項式と見ての最高次数
# mindeg(var) # var の多項式と見ての最低次数
# lcm_coeff_denom
#     lcm of denominator of coefficients as Rarional
# gcd_coeff_num
#    gcd of numerator of coefficients as Rational
#
# TESTING:
# <=>
#    Now, same as self.lt<=>other.lt
# ==
# zero?
#      Is zero?
#
# CONVERTING:
# PolynomialM(arg) or PolyM(arg)
#      arg admit Numeric,String,Monomial,Polynomial
#      Recommended than new, beacuse of checking var names.
#      Use as PolynomialM("2*x+3*y**2+z*x")
#      Note that "xy" means name xy, not x*y.
#      (name match /[a-z][a-zA-Z0-9_]*/)
# P_.var
#     same as PolyM("var")
# PolynomialM.new(monomials)
#      monomials be Array of Monomial
# to_s(format)
#       format: "text" then "5x^(4)+3x^(2)+1"  (default)
#				"tex"       "5x^{4}+3x^{2}+1"
#               "texm"      "$5x^{4}+3x^{2}+1$"
#               "prog"      "5*x**(4)+3*x**(2)+1"
# coeff_to_Zp(p)
#     Convert each coefficient to (mod p) for Integer coefficient polynomial.
# coeff_to_Z
#     Rational係数多項式を定数倍して Z係数かつ係数のGCDを1にする.
#       Bug.
#          Float, Complex 係数の動作は保証しない.
# coeff_to_f
#      converts each element to Float
# coeff_truncate 
#      truncate each coefficient to Integer
# normalize!
# sort!
#      sort terms in decreasing order. higher term is top.
#
#########################
#
# class Monomial
# Monomial(c,p)
#    generate new Monomial
#    c be coefficient
#    p be Hash of "var"=>power
#    Recommended than new, beacuse checking var names.
# Monomial.new(c,p)
#     generate new Monomial
#     c be coefficient
#     p be Hash of "var"=>power
# normalize!
# to_s(format)
#       format: "text" then "5x^4+3x^2+1"  (default)
#				"tex"       "5x^{4}+3x^{2}+1"
#               "texm"      "$5x^{4}+3x^{2}+1$"
#               "prog"      "5*x**4+3*x**2+1"
# Monomial.setTermOrder(t)
# Monomial.getTermOrder
#        t= "lex"(default), "deglex",  "degrevlex"
#        set/get term order
# Monomial.setVarOrder(order)
# Monomial.getVarOrder
# Monomial.appendVarName(v) # Assume that v be String
#     set/get/append var. order
#     default VarOrder is:
#     ["x","y","z","u","v","w","p","q","r","s","t",
#     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o"]
# powerProduct
# lcm(other)    lcm of power product
# gcd(other) # gcd of power product
# +,-        needed have same power product
# *
# -@
#     return -self
# divisible?(other)
# /(monomial)
#       divide.  Assume self.divisible?(other)
# divmodI(m)
#       divide.  Assume self.divisible?(other)
#       return quotient, residue
#       quotient has Integer coefficient, residue>=0
# divZp(m,p)
#       divide.  Assume self.divisible?(other)
# totalDegree
# <=>
#       1: self>m, 0: self=m, -1: self<m 
# lex(m),revlex(m),deglex(m),degrevlex(m)
#        Note that revlex is not a term order.
# 
#####################################
# NOT IMPLEMENTED or IMPERFECT
#  PolynomialM#<=>(other)

require "rational"
require "number"
require "polynomial"



# Example.
# a = (P_.x**2 - P_.y**2) / (P_.x - P_.y)
# print a, "\n" # => "x+y"

P_ = Object.new
def P_.method_missing(*a)
	PolynomialM(a[0].id2name)
end


def PolynomialM(poly_arg1=0,*poly_arg2)
    case poly_arg1
    when PolynomialM; return poly_arg1
    when Numeric; 
		if poly_arg2[0].kind_of?(Hash);
			#coefficient and power product like Monomial
			return PolynomialM.new([Monomial(poly_arg1,poly_arg2[0])])
		else return PolynomialM.new([Monomial.new(poly_arg1,{})])
		end
	when String; 
		# generate var-names as variables in Ruby
		# and eval the expression
		poly_str=PolyWork.cnv_prog_format(poly_arg1)
		for var_name in poly_str.scan(/[a-z][a-zA-Z0-9_]*/)
			eval var_name+"=PolynomialM.new([Monomial(1,{var_name=>1})])"
		end
		# for Rational expression
		poly_str=poly_str.gsub(/\//,"*poly_one/")
		poly_one=PolynomialM.new([Monomial(1,{})])
		reply=eval poly_str;
		return PolynomialM(reply)
	when Polynomial; return PolynomialM(poly_arg1.to_s("prog"))
	when Monomial; # sequence of Monomial
		return PolynomialM.new([poly_arg1]+poly_arg2)
	when Array;
		if poly_arg1[0].kind_of? Monomial
			return PolynomialM.new(poly_arg1) # Array of Monomial
		else; # A generating function. May be.
			return PolynomialM(Polynomial(poly_arg1)) 
		end
    else; raise TypeError
    end
end


alias PolyM PolynomialM


def Monomial(c=0,p={}) # coefficient and power product
p.each_key{|v| Monomial.appendVarName(v)}
return Monomial.new(c,p)
end


class Monomial

# c: coefficient, p: hash of pair "variable"=>degree
def initialize(c=0,p={})
	@coeff=c
	@power=Hash.new(0)
	p.each_pair{|k,v| @power[k]=v} # @power.replace(p)
end

attr_accessor :coeff
attr_accessor :power

def clone
	m=Monomial.new(@coeff,@power.clone); return m
end

def normalize!
	@power.each{|v,p| if 0==p; @power.delete(v);end}
end


def to_s(format="text")
    case format
    when "text"; timeC=""; timeV="*";power1="^(";power2=")"; ms=""; me=""
    when "tex"; timeC=""; timeV="";power1="^{";power2="}"; ms=""; me=""
    when "texm"; timeC=""; timeV="";power1="^{";power2="}"; ms="$"; me="$"
    when "prog"; timeC="*"; timeV="*"; power1="**(";power2=")"; ms=""; me=""
    end
	# timeC: 係数と変数間の記号
	# timeV: 変数間の分離記号
	# power1, power2: 指数部の開始と終了
	# ms,me: 数式全体のくくり
	c=@coeff
	if c<0; sign="-";c=-c;else; sign="";end
	if c.kind_of?(Rational)&&(c.denominator != 1);
		den="/"+c.denominator.to_s; c=c.numerator
	else
		den=""
	end
	vs=""; ts=""
	VarOrder.each{|v|
		d=@power[v]
		if d != 0;	vs=vs+ts+v; ts=timeV
			if d>1;vs=vs+power1+d.to_s+power2;end
		end
	}
	str=sign
	if (c != 1)||(vs==""); str=str+c.to_s;end
	if (c != 1)&&(vs != "");str=str+timeC;end
	str=str+vs+den
	return str
end


def powerProduct
m=Monomial.new(1,@power); return m
end


def lcm(other) # lcm of power product
	m=Monomial.new(1,{})
	VarOrder.each{|v|
		d=[@power[v],other.power[v]].max
		if m != 0; m.power[v]=d ;end
	}
	return m
end


def gcd(other) # gcd of power product
	m=Monomial.new(1,{})
	VarOrder.each{|v|
		d=[@power[v],other.power[v]].min
		if m != 0; m.power[v]=d ;end
	}
	return m
end

def -@
	return Monomial.new(-@coeff,@power)
end

def negate!
	@coeff=-@coeff; return self
end


# Assume that power is the same.
def +(m)
if m.kind_of?(Monomial)&&(0==(self<=>m))
	return Monomial.new(@coeff+m.coeff,@power)
elsif m.kind_of?(Monomial)||M.kind_of?(Numeric)
	return PolynomialM(self)+PolynomialM(other)
elsif m.kind_of?(PolynomialM)
	return PolynomialM(self)+other
else
	x , y = m.coerce(self)
	return x+m
end
end


# Assume that power is the same.
def -(m)
return self+(-m)
end


def *(m)
if m.kind_of?(Monomial)
	c=@coeff*m.coeff
	p=@power.clone
	m.power.each_pair{|v,d| p[v]=p[v]+d}
	return Monomial.new(c,p)
elsif m.kind_of?(Numeric)
	return Monomial.new(@coeff*m,@power)
else
	x , y = m.coerce(self)
	return x*m
	#raise TypeError
end
end

# Rational 係数で 割れるかどうかを調べる.
def divisible?(divisor)
if @coeff==0;return false;end
divisor.power.each_pair{|v,d| if @power[v]<d;return false;end}
return true
end

def /(m)
if m.kind_of?(Monomial)# && self.divisible?(m);
	q=Number.divII(@coeff,m.coeff)
	p=@power.clone
	m.power.each_pair{|v,d| p[v]=p[v]-d} # determine exponents
	return Monomial.new(q,p)
elsif m.kind_of?(Numeric)
	return Monomial.new(Number.divII(@coeff,m),@power)
else
	raise TypeError
end
end

# Integer 係数の term として割れるかどうかを調べる. 係数は無視.
def divisibleI?(divisor)
if (0<=@coeff)&&(@coeff<divisor.coeff.abs);return false;end
divisor.power.each_pair{|v,d| if @power[v]<d;return false;end}
return true
end

def divmodI(m)
if m.kind_of?(Monomial)# && self.divisible?(m);
	q=Number.divFloor(@coeff,m.coeff)
	r=@coeff-q*m.coeff # Note that r>=0
	p=@power.clone
	m.power.each_pair{|v,d| p[v]=p[v]-d} # determine exponents
	return Monomial.new(q,p),Monomial.new(r,p)
elsif m.kind_of?(Numeric)
	q=Number.divFloor(@coeff,m)
	r=@coeff-q*m # Note that r>=0
	return Monomial.new(q,@power),Monomial.new(r,@power)
else
	x , y = m.coerce(self)
	return x*m
	#raise TypeError
end
end

def divZp(m,prime)
if m.kind_of?(Monomial)# && self.divisible?(m);
	q=Number.modP(@coeff*Number.inv(m.coeff,prime),prime)
	p=@power.clone
	m.power.each_pair{|v,d| p[v]=p[v]-d} # determine exponents
	return Monomial.new(q,p)
elsif m.kind_of?(Integer)
	q=Number.modP(@coeff*Number.inv(m,prime),prime)
	return Monomial.new(q,@power)
else
	 raise TypeError
end
end

def coerce(x)
	case x
	when Numeric; return PolynomialM(x), PolynmialM(self)
	when Monomial; return PolynomialM(x), PolynmialM(self)
	when Polynomial; return PolynomialM(x),PolynmialM(self)
	when PolynomialM; return x,PolynmialM(self)
	else ; raise TypeError
	end
end


### degree & order ###

def totalDegree
deg=0
@power.each_value{|d| deg=deg+d}
return deg
end


#  lex(lexicographical),
#  revlex(ReverseLexicographical)
#       Note that "revlex" is not a term order.
#  deglex(degreeLexicographical)
#  degrevlex(degreeReverseLexicographical)

TermOrder=["lex"] # "lex" "deglex" "degrevlex"

def Monomial.setTermOrder(t="lex") # t= "lex" "deglex" "degrevlex"
	TermOrder[0]=t
end

def Monomial.getTermOrder
	return TermOrder[0]
end

VarOrder0=["x","y","z","u","v","w","p","q","r","s","t"]+
	["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o"];
VarOrder=VarOrder0.dup

def Monomial.setVarOrder(order=VarOrder0)
VarOrder.replace(order)
end

def Monomial.getVarOrder
return VarOrder.dup
end

def Monomial.appendVarName(v) # Assume that v be String
if !VarOrder.include?(v); VarOrder.push(v);end
end

def lex(m) #lexical order
for i in 0..VarOrder.size-1
	if @power[VarOrder[i]] != m.power[VarOrder[i]];
		return @power[VarOrder[i]]<=>m.power[VarOrder[i]]
	end
end
return 0
end


def revlex(m)
i=VarOrder.size-1
while i>=0
	if @power[VarOrder[i]] != m.power[VarOrder[i]];
		return -(@power[VarOrder[i]]<=>m.power[VarOrder[i]])
	end
	i=i-1
end
return 0
end

def deglex(m)
t1=self.totalDegree; t2=m.totalDegree
if t1 != t2; return t1<=>t2;end
return self.lex(m)
end

def degrevlex(m)
t1=self.totalDegree; t2=m.totalDegree
if t1 != t2; return t1<=>t2;end
return self.revlex(m)
end


# 1: self>m, 0: self=m, -1: self<m 
def <=>(m)
	case TermOrder[0]
	when "lex"; return self.lex(m)
	when "deglex";return self.deglex(m)
	when "degrevlex";return self.degrevlex(m)
	end
end


end # Monomial


#########################################

class PolynomialM  # Polynomial of Multi Variable


def initialize(monomials=[])  # Polynomial is sequence of Monomials.
	@monomials=monomials
end

attr :monomials

def clone
	ms=[]
	@monomials.each{|m| ms.push(m.clone)}
	p=PolynomialM.new(ms)
	return p
end


def to_s(format="text")
    case format
    when "text"; timeC=""; timeV="*";power1="^(";power2=")"; ms=""; me=""
    when "tex"; timeC=""; timeV="";power1="^{";power2="}"; ms=""; me=""
    when "texm"; timeC=""; timeV="";power1="^{";power2="}"; ms="$"; me="$"
    when "prog"; timeC="*"; timeV="*"; power1="**(";power2=")"; ms=""; me=""
    end
	# timeC: 係数と変数間の記号
	# timeV: 変数間の分離記号
	# power1, power2: 指数部の開始と終了
	# ms,me: 数式全体のくくり
	s=""; addS=""
	@monomials.each{|m|
		if (m.coeff>0); s=s+addS;end
		s=s+m.to_s(format); addS="+"
	}
	if (s==""); s="0";end
	s=ms+s+me # math start and math end
	return s
end


def normalize!
@monomials.each_with_index{|m,i| 
	if m.coeff==0; @monomials[i]=nil; # 係数 0の項を除く
	else @monomials[i].normalize! # 単項式の正規化
	end
}
@monomials.compact!;
self.sort!
i0=0; # power product が同じ項が複数あればまとめる.
for i1 in 1..@monomials.size-1
	if 0==(@monomials[i0]<=>@monomials[i1]);
		@monomials[i0] += @monomials[i1];
		@monomials[i1]=nil;
	else if @monomials[i0].coeff==0;@monomials[i0]=nil;end;
		i0=i1
	end
end
if (i0<@monomials.size)&&(@monomials[i0].coeff==0);@monomials[i0]=nil;end;
@monomials.compact!
end


def lt # leading term
if self.zero?; return Monomial(0)
else return @monomials[0]
end
end

def lc # leading coefficient
if self.zero?; return 0
else return @monomials[0].coeff
end
end

def lp # leading power product
if self.zero?; return Monomial(1)
else return @monomials[0].powerProduct
end
end

def unit?
if 0<self.lp.totalDegree; return false;end
lc=self.lc
return (lc.abs==1)||(lc.kind_of?(Rational))||(lc.kind_of?(Float))
end


def coeff(var,deg) # v の多項式と見ての deg 次の係数多項式を返す.
p=PolynomialM.new
@monomials.each{|m|
	if m[var]==deg;m1=m.clone; m1.delete(var);p.monomials.push(m1);end
}
p.normalize!; return p
end


def vars # 式に含まれる 変数名一覧
vs=[]
@monomials.each{|m|
	m.powers.each_key{|v|
		if ! vs.include(v); vs.push(v);end
	}
}
vorder=Monomial.getVarOrder
vs.sort!{|v1,v2| vorder.index(v1)<=>vorder.index(v2)}
return vs
end

def maxdeg(var) # var の多項式と見ての最高次数
deg=0
@monomials.each{|m|	if deg<m.power[var]; deg=m.power[var];end}
return deg
end

def mindeg(var) # var の多項式と見ての最低次数
deg=nil
@monomials.each{|m| if (deg==nil)||(deg<m[var]); deg=m[var];end}
if deg==nil; deg=0;end
return deg
end

def sort!  # decreasing order. higher term is top.
## print "polym sort! "+self.to_s+" size="+@monomials.size.to_s+"\n";
## @monomials.each{|m| print "["+m.to_s+"]"};
## print "\n";
@monomials.sort!{|m1,m2| m2 <=> m1}
end

def zero?
self.normalize!; return @monomials.empty?
end

def <=>(other)
	return self.lt<=>other.lt
end

def <(other)
	return (self.lt<=>other.lt)<0
end

def ==(other)
return (self-other).zero?
end

def coerce(x)
	case x
	when Numeric; return PolynomialM.new([Monomial.new(x,{})]), self
	when Monomial; return PolynomialM.new([x]), self
	when Polynomial; return PolynomialM(x),self
	else ; raise TypeError
	end
end


def negate!
@monomials.each_index{|i| @monomial[i].negate!}
return self
end

def negate
p=PolynomialM.new
@monomials.each{|m| p.monomials.push(-m)} 
return p
end

alias -@ negate

def +(other)
if other.kind_of?(PolynomialM);
	# concatiname as Array and simplify it.
	p3=self.clone
	p3.monomials.concat(other.monomials)
	p3.normalize!
	return p3
	#
	#p3=PolynomialM.new([])
	#p1=self.clone; p1.sort!; p1.normalize!; s1=p1.monomials.size
	#p2=other.clone;p2.sort!;p2.normalize!; s2=p2.monomials.size
	#i1=0;i2=0; m1=p1.monomials[i1]; m2=p2.monomials[i2]
	#while (i1<s1)||(i2<s2)
	#	if i1>=s1; l=-1
	#	elsif i2>=s2; l=1
	#	else l=(m1 <=> m2)
	#	end
	#	if l==0; 
	#		m3=m1+m2
	#		p3.monomials.push(m3);
	#		i1=i1+1;i2=i2+1; m1=p1.monomials[i1]; m2=p2.monomials[i2]
	#	elsif l==-1;p3.monomials.push(m2);
	#		i2=i2+1; m2=p2.monomials[i2]
	#	else;p3.monomials.push(m1);
	#		i1=i1+1; m1=p1.monomials[i1]
	#	end
	#end
	#return p3
elsif other.kind_of?(Monomial)||other.kind_of?(Numeric)
	return self+PolynomialM(other)
else
	x , y = a.coerce(self)
	return x+y
end
end


def -(other)
	return self+(-other)
end


def *(other)
if other.kind_of?(PolynomialM);
	p=PolynomialM.new([])
	pw=PolynomialM.new([])
	@monomials.each{|m1|
		pw.monomials.clear
		other.monomials.each{|m2|
			pw.monomials.push(m1*m2)
		}
		p=p+pw
	}
	return p
elsif other.kind_of?(Numeric);
	p=self.clone
	p.monomials.each{|m| m.coeff *= other}
	return p
elsif other.kind_of?(Monomial)
	return self*PolynomialM(other)
else
	x , y = a.coerce(self)
	return x*y
end
end


def **(n)
	if n.kind_of?(Integer)
	# calculate ** following to binary notation of "power".
		s=PolynomialM.new([Monomial.new(1,{})])
		p=self.clone;p.normalize!;
		while n>0
			if n&1==1; s=s*p;end
			p=p*p; n >>= 1
		end
		return s
	else raise TypeError
	end
end


def divmod(divisors) # return q[],r
if divisors.kind_of?(Array)&& divisors[0].kind_of?(PolynomialM);
	# Multiple division.
	# "divisors" and quotient "q" are Array of PolynomialM
	h=self.clone; h.normalize!
	# sort as heigher be top
	#divisors.sort!{|f1,f2| f2.lt<=>f1.lt};
	ltD=[];# leading terms of divisors
	q=[]; # quotients
	divisors.each_with_index{|f,i| ltD[i]=f.lt;	q[i]=PolynomialM.new;}
	r=PolynomialM.new; pw=PolynomialM.new
	while ! h.monomials.empty?
		i=0
		ltH=h.lt
		while i<ltD.size
			if ltH.divisible?(ltD[i])
				qt=ltH/ltD[i];
				q[i].monomials.push(qt)
				pw.monomials.replace([qt])
				h=h-(pw*divisors[i])
				if h.monomials.empty?;break;end
				ltH=h.lt
				i=0
			else
				i=i+1
			end
		end
		if !h.monomials.empty?; r.monomials.push(ltH); h.monomials.shift; end
	end
	return q,r
elsif divisors.kind_of?(PolynomialM);
	return self.divmod([divisors])
elsif divisors.kind_of?(Numeric);
	p=self.clone
	p.monomials.each{|m| m.coeff = Number.divII(m.coeff,divisors)}
	return [p],PolynomialM(0)
elsif divisors.kind_of?(Monomial)
	return self.divmod([PolynomialM(divisors)])
else
	x , y = divisors.coerce(self)
	return x.divmod(y)
end
end


def /(other) # other be PolynomialM
q,r=self.divmod(other); return q[0]
end


def %(other) # other be PolynomialM
q,r=self.divmod(other); return r
end


def divmodZp(divisors,p) # return q[],r
if divisors.kind_of?(Array)&& divisors[0].kind_of?(PolynomialM);
	# Multiple division.
	# "divisors" and quotient "q" are Array of PolynomialM
	h=self.coeff_to_Zp(p);
	#divisors.sort!{|f1,f2| f2.lt<=>f1.lt};
	ltD=[];# leading terms of divisors
	q=[]; # quotients
	divisors.each_with_index{|f,i| ltD[i]=f.lt; q[i]=PolynomialM.new;}
	r=PolynomialM.new; pw=PolynomialM.new
	while ! h.monomials.empty?
		ltH=h.lt
		i=0;
		while i<ltD.size
			if ltH.divisible?(ltD[i])
				qt=ltH.divZp(ltD[i],p);
				q[i].monomials.push(qt)
				pw.monomials.replace([qt])
				h=h-(pw*divisors[i])
				h=h.coeff_to_Zp(p);
				if h.monomials.empty?;break;end
				ltH=h.lt
				i=0;
			else
				i=i+1
			end
		end
		if !h.monomials.empty?; r.monomials.push(ltH); h.monomials.shift; end
	end
	r=r.coeff_to_Zp(p)
	return q,r
else
	return self.divmodZp([PolynomialM(divisors)])
end
end



def divmodI(divisors) # return q[],r
if divisors.kind_of?(Array)&& divisors[0].kind_of?(PolynomialM);
	# Multiple division.
	# "divisors" and quotient "q" are Array of PolynomialM
	h=self.clone; h.normalize!
	#divisors.sort!{|f1,f2| f2.lt<=>f1.lt};
	ltD=[];# leading terms of divisors
	q=[]; # quotients
	divisors.each_with_index{|f,i| ltD[i]=f.lt; q[i]=PolynomialM.new;}
	r=PolynomialM.new; pw=PolynomialM.new
	while ! h.monomials.empty?
		ltH=h.lt;
		i=0;
		while i<ltD.size
			if ltH.divisibleI?(ltD[i])
				qt,rt=ltH.divmodI(ltD[i]);
				q[i].monomials.push(qt)
				pw.monomials.replace([qt])
				h=h-(pw*divisors[i])
				if h.monomials.empty?;break;end
				ltH=h.lt;
				i=0;
			else
				i=i+1
			end;
		end
		if !h.monomials.empty?; r.monomials.push(ltH); h.monomials.shift; end
	end
	return q,r
elsif divisors.kind_of?(Numeric);
	return self.divmodI([PolynomialM(divisors)])
else
	return self.divmodI([PolynomialM(divisors)])
end
end



def substitute(list) # list is Hash of "var"=>val
f=PolynomialM.new
self.monomials.each{|m|
	fw=PolynomialM(m.coeff)
	m.power.each_pair{|var,deg|
		if list.has_key?(var); fw1=list[var]**deg
		else fw1=PolynomialM.new([Monomial.new(1,{var=>deg})])
		end
		fw=fw*fw1
	}
	f=f+fw
}
return f
end


def derivative(vars) # vars is Array of var names
f=self.clone
for m in f.monomials
	for var in vars
		if m.power.has_key?(var);
			p=m.power[var];
			m.coeff=m.coeff*p
			if p==1; m.power.delete(var); else; m.power[var]=p-1; end
		else m.coeff=0; break
		end
	end
end
f.normalize!
return f
end


def integral(vars) # vars is Array of var names
f=self.clone
for m in f.monomials
	for var in vars
		if m.power.has_key?(var);
			p=m.power[var]+1;
			m.power[var]=p;
			m.coeff=Number.divII(m.coeff,p);
		else m.power[var]=1
		end
	end
end
f.normalize!
return f
end

def lcm_coeff_denom # lcm of of denominator of coefficients as Rarional
den=[1]
@monomials.each{|m| c=m.coeff;
	if c.kind_of?(Rational); den.push(c.denominator.abs);end
}
return Number.lcm(den)
end

def gcd_coeff_num # gcd of numerator of coefficients as Rational
num=[1]
@monomials.each{|m| c=m.coeff;
	if c.kind_of?(Rational)||c.kind_of?(Integer); num.push(c.numerator.abs);end
}
return Number.gcd(num)
end

def coeff_truncate # truncate each coefficient to Integer
f=self.clone
for i in 0..f.monomials.size-1;
	f.monomials[i].coeff=f.monomials[i].coeff.to_i
end
f.normalize!
return f
end

def coeff_to_f # converts each element to Float
f=self.clone
for i in 0..f.monomials.size-1;
	f.monomials[i].coeff=f.monomials[i].coeff.to_f
end
f.normalize!
return f
end

def coeff_to_Z # Rational係数多項式を定数倍して Z係数かつ係数のGCDを1にする.
f=self*self.lcm_coeff_denom
f=f/f.gcd_coeff_num
f=f.coeff_truncate
return f
end

def coeff_to_Zp(p)
f=self.clone
for i in 0..f.monomials.size-1;
	f.monomials[i].coeff=Number.modP(f.monomials[i].coeff,p);
end
f.normalize!
return f
end

def inspect
sprintf("PolynomialM(%s)",@monomials.join(","))
end

end #PolynomialM



if $0 == __FILE__
# test code
f=PolynomialM("x+y^2").substitute("x"=>PolynomialM("y"),"y"=>PolynomialM("x"))
print f,"\n"
end
