=begin
 class Polynomial
    Class of 1 variable polynomial.
    Coefficients admit Integer,Rationall,Complex and Float.(BigFloat, may be.)
    Use package as follows.
    require "polynomial"

###########################################
 refinement *, times and timesSep
    K.Kodama 2001-11-23

 refinement checkDivZe,checkZp and setPoly
   by toyofuku@jiuce.or.jp 2000-03-10 

 [] []= by Masaki Suketa 2000-01-22

 Thaks to Hideto ISHIBASHI and Masaki Suketa for their suggestion.
 
 K.Kodama(kodama@kobe-kosen.ac.jp) 2000-01-09 
   first version

This module is distributed freely in the term of 
GNU General Public License(GPL).
###########################################

 class Polynomial
 RESTRICTION:
    Cannot omit inner 0s. Use normalize!
 TESTING:
    zero?
       Is zero?
    <=>(other)
    ==(other)
 ARITHMETIC:
   self.normalize!
        suppress heigher 0s and fill up inner 0s
   degree #degree of the polynomial
   lc # leading coefficient
   lp # leading power product
   lt # leading term
   mindeg # minimum degree of non-zero term
   +
   -
   *
   /
   %
   **(n)
       power. n>=0 
   powerModI (power, m, n=0)
       return self**power mod m
       power>=0, m:polynomial
       coefficient to mod n, if n:positive integer.
   divmod(divisor) 
       divide
       return quotient,remainder
       Assume that coefficient is field.
       Integer is subset of Rational.
   div(divisor)
   mod(divisor)
   divmodR(divisor)
       divide
       return quotient,remainder
       Assume that coefficient ring may be not a field (but support /).
       Integer is treated as a kind of Rational when mathn is loaded.
   divmodI(poly)
       return quotient,remainder
       divide in the ring Z
       Coefficients of quotient are Integer.
       So, degree of remainder can be greater than divisor.
   modI(poly)
   divI(poly)
   divmodZp(poly,p)
       return quotient,remainder
       divide in Zp
   modZp(poly,p)
   divZp(poly,p)
   derivative(n=1)
       n-th derivative
   integral(n=1)
       integral n-times
   substitute(x)
       substitute x. "x" admit Integer, Rational, Float, Polynomial....
   substitute_reverse(a=1,m=0)
	  (self*(a^(degree))).substitute(x/a) (mod m)
	  e.g. x^3 + x^2 + x + 1 --> x^3 + a x^2 + a^2 x + a^3
   factorize
       factorize "integer" coefficient polynomial
       return [factor1, factir2,...]
  Polynomial.lcm([f0,f1...])
       LCM
  Polynomial.gcd([f0,f1...])
       GCD
  Polynomial.gcd2([f0,f1...])
       return gcd,*c
       s.t. gcd=c[0]*f0+c[1]*f1+....
 Polynomial.gcdZp(prime,a,*b)
       GCD with Zp coefficients
 Polynomial.gcd2Zp(prime,a,*b)
       GCD with Zp coefficients
       return gcd,*c
       s.t. gcd=c[0]*f0+c[1]*f1+.... (mod prime)
    [], []=, array
         To access coefficients of terms,
         write p[1]=p[2] or p.array[1]=p.array[2].
 lcm_coeff_denom
     lcm of denominator of coefficients as Rarional
 gcd_coeff_num
    gcd of numerator of coefficients as Rational
 countSolution(a=-Infinity,b=Infinity, countRedundancy=true)
     count nouber of solution between a and b using Sturm's algorithm.
     a and b be Integer,Rational,Float, -Infinity or Infinity
 squareFreeDecomposition
 Polynomial.constructionHensel(f,g,h,n,prime,pn)
     Hensel's construction.
     Input: f,g,h,n,prime,pn  s.t. f==g*h (mod pn), pn=prime^n
     Output: g,h  s.t. f==g*h (mod prime^(n+1)) 
 CONVERTING:
   Polynomial.term(c=0,n=0,one=1)
       generate term c*x^n
   Polynomial(arg)  or Poly(arg)
       generate polynomial
        Convert Array, Numeric, String to Polynomial
        String admit both "5x^4+3x^2+1" and "5*x**4+3*x**2+1"
        Use "x" for variable.
       Polynomial([5,6,7])=5+6x+7x^2
       Polynomial(5,6,7)=5+6x+7x^2
       Polynomial("5+6x+7x^2")=5+6x+7x^2
       Polynomial("5+6*x+7*x**2")=5+6x+7x^2
    Polynomial.gen_func(array)
        Convert Array to Polynomial as a sequence of coefficients.
        Obtain generating function for the array.
    Polynomial.exp_gen_func(array)
        Obtain exponential generating function for the array.
    to_poly
        Obsolete. Use Polynomial(arg).
    to_a
        Converts to Array of a sequence of coefficients
    coeff_truncate
        Converts each coefficient to Integer by trancate
    coeff_round
        round each coefficient to Integer
    coeff_to_Z
       Get Z-coefficient polynomial from Rational-coefficient polynomial
       with multiply a Rational.
       Bug.
          Not assure on Float or Complex coefficient.
   coeff_to_real
        Converts each coefficient to real if Complex
   coeff_to_f
        Converts each coefficient to Float
   coeff_to_Zp(p, positive=true)
       Convert each coefficient to (mod p) for Integer coefficient polynomial.
   to_s(format="text",v="x", r=true)
       Returns string representation
       var is name of variable
       order: true=heigher term to lower, false=reversed
       format: "text" then "5x^4+3x^2+1"
				"tex"       "5x^{4}+3x^{2}+1"
               "texm"      "$5x^{4}+3x^{2}+1$"
               "prog"      "5*x**4+3*x**2+1"
   Polynomial.factor2s(factor,sep=" ")
        Return string representation for result of "factorize"
=end

require "number.rb"


module PolyWork # Work routines for polynomial

def cnv_prog_format(str)
# convert from "tex", "texm" or "text" format to "prog" format
# c.f. Polynomial("str")
s=str.clone
s=s.gsub(/ \t/,"") # has no-space
s=s.gsub(/\^/,"**") # power be **
#vanish TeX symbol $, and {,} convert to (,).
s=s.gsub(/\$/,"").gsub(/[{]/,"(").gsub(/[}]/,")")
# insert "*" between coefficient and variable
s=" "+s
s=s.gsub(/[^a-zA-Z_0-9][0-9]+[a-z]/){|m| m.gsub(/[a-z$]/){|v| "*"+v}}
# insert "*" near brackets (  )
s=s.gsub(/[a-zA-Z0-9\)][ \t]*\(/){|m| m[1]="*";m+"("} # A( --> A*(
s=s.gsub(/\)[ \t]*[a-zA-Z0-9\(]/){|m| m[0]="*";")"+m} # )B --> )*B
return s
end

module_function :cnv_prog_format
end # PolyWorks


def Polynomial(poly_arg1=[0], one=1)
    case poly_arg1
	when Polynomial; return poly_arg1.clone
    when Array; return Polynomial.new(poly_arg1,one).normalize!
    when Numeric; return Polynomial.new(poly_arg1,one)
	when String; 
		poly_str=PolyWork.cnv_prog_format(poly_arg1)
		# convert variavles to "x"
		poly_str=poly_str.gsub(/[a-z][a-zA-Z0-9_]*/,"x")
		# for Rational expression
		poly_str=poly_str.gsub(/\//,"*poly_one/")
		poly_one=Polynomial.new([one],one)
		x=Polynomial.new([one-one,one])
		reply=eval poly_str;
		return Polynomial(reply)
    else; raise TypeError
    end
end


alias Poly Polynomial


class Polynomial

def initialize(a=[0],one=1)
    case a
    when Array; @array = a
    when Numeric; @array = [a]
    else; raise TypeError
    end
	@one=one; @zero=one-one;
	self.normalize!
end

private :initialize
attr_accessor :array
attr_accessor :one
attr_accessor :zero

def inspect
	s=""; print "["
	@array.each_index{|k| print s+k.to_s; s=","}
	print "]\n"
end

def [](i)
	if i>=@array.size; return @zero; end;
	return @array[i]
end

def []=(i, c)
	l0=@array.size; if l0<i; @array.fill(@zero,l0..i); end
	@array[i]=c
end

def clone
	f=Polynomial.new([@zero],@one); f.array.replace(@array);
	return f
end

def Polynomial.term(c=0,n=0,one=1)
	z=one-one; if n<0; c=z; n=0;elsif c==z; n=0;end;
	f=Polynomial.new(0,one); f.array.fill(z,0..n); f.array[n]=c;
	return f
end

def Polynomial.gen_func(array,one=1) # generating function.
	return Polynomial(array,one)
end

def Polynomial.exp_gen_func(array,one=1) # exponential generating function
f=Polynomial(array,one)
f.array.each_with_index{|x,i|
	f.array[i]=Number.divII(x,Number.factorial(i))
}
return f
end

def degree # (maximum degree of nonzero term) or 0
	d=@array.length-1
	if d<0; @array[0]=@zero; return 0;end;
	while (d>0)&&(@array[d]==@zero);d -= 1;end
	return d
end

def mindeg # (minimum degree of non-zero term) or 0.
	d=self.degree; dm=0;
	while (dm<d)&&(@array[dm]==@zero); dm += 1; end
	return dm
end


def lc # leading coefficient
	return @array[-1]
end

def lp # leading power product
	return Polynomial.term(@one,self.degree,@one)
end

def lt # leading term
	return Polynomial.term(@array[-1],self.degree,@one)
end

def normalize!  ### Note that @array[0]==0 for polynomial "0".
	#@array.each_index{|i| if nil==@array[i]; raise "nil in poly." ;end}
	#@array.each_index{|i| if nil==@array[i]; @array[i]=@zero;end}
	d0=d=@array.length-1; if d<0; @array=[@zero]; return self; end;
	while (d>0)&&(@array[d]==@zero);d -= 1;end
	if d<d0; @array=@array[0..d]; end
	return self
end

def zero?
	return (@array[0]==@zero)&&(self.degree==0)
end

def unit?
	if @array.size != 1; return false;end
	lc=@array[0]
	return (lc==@one)||(lc==-@one)||(lc.kind_of?(Rational))||(lc.kind_of?(Float))
end

def negate
	p=self.clone; p=p.normalize!;
	p.array.each_with_index{|a,i| p.array[i] = -a};
	return p
end

alias -@ negate

def + (other)
	if other.kind_of?(Polynomial)
		d1=self.degree; d2=other.degree
		if d1==d2;
			a=self.clone; 0.upto(d2){|i| a.array[i] += other.array[i]}
			return a.normalize!
		elsif d1>d2;
			a=self.clone; 0.upto(d2){|i| a.array[i] += other.array[i]}
			return a
		else # d1<d2
			a=other.clone; 0.upto(d1){|i| a.array[i] += @array[i]}
			return a
		end
	elsif other.kind_of?(@one.class) or other.kind_of?(Numeric) 
		a=self.clone; a.array[0]+=other; return a.normalize!
	elsif other.kind_of?(RationalPoly)
		return RationalPoly(self)+other
	else x,y=other.coerce(self)
		return x+y
	end
end

def - (other)
	#return self + (-other)
	if other.kind_of?(Polynomial)
		d1=self.degree; d2=other.degree
		if d1==d2;
			a=self.clone; 0.upto(d2){|i| a.array[i] -= other.array[i]}
			return a.normalize!
		elsif d1>d2;
			a=self.clone; 0.upto(d2){|i| a.array[i] -= other.array[i]}
			return a
		else #d1<d2
			a=self.clone; a.array.fill(@zero,d1+1..d2)
			0.upto(d2){|i| a.array[i] -= other.array[i]}
			return a
		end
	elsif other.kind_of?(Numeric)
		a=self.clone; a.array[0]-=other; return a.normalize!
	elsif other.kind_of?(@one.class)
		a=self.clone; a.array[0]-=other; return a.normalize!
	elsif other.kind_of?(RationalPoly)
		return RationalPoly(self)-other
	else x,y=other.coerce(self)
		return x+y
	end
end


def timesCnv (other)
	# convolution
	a=Polynomial.new(@zero,@one);
	a.array.fill(@zero,0..self.degree+other.degree)
	@array.each_with_index{|x,i| 
		if x!=@zero;
			other.array.each_with_index{|y,j| a.array[i+j] += x*y};
		end;
	}
	return a.normalize!
end

def timesSep(p2,d1,d2)
	# return self*p2. Assume that d1>=d2. d1=self.degree, d2=p2.degree
	d00=25
	d=d2.div(2) # d1>=d2>=2d
	# separating polynomials to upper/lower part.
	p1a=Polynomial.new(@zero,@one);p1a.array=@array[d+1..d1]; d1a=d1-d-1
	p1b=Polynomial.new(@zero,@one);p1b.array=@array[0..d]; p1b.normalize!; d1b=p1b.degree
	p2a=Polynomial.new(@zero,@one);p2a.array=p2.array[d+1..d2]; d2a=d2-d-1
	p2b=Polynomial.new(@zero,@one);p2b.array=p2.array[0..d]; p2b.normalize!; d2b=p2b.degree
	if d2a>=d00; aa=p1a.timesSep(p2a,d1a,d2a); else aa=p1a.timesCnv(p2a); end
	if (d1b>=d2b); if (d2b>=d00); bb=p1b.timesSep(p2b,d1b,d2b); else bb=p1b.timesCnv(p2b); end;
	else if (d1b>=d00); bb=p2b.timesSep(p1b,d2b,d1b); else bb=p1b.timesCnv(p2b); end;
	end
	if d1b>=d1a; p1c=p1b; 0.upto(d1a){|i| p1c.array[i]+=p1a.array[i]}
	else p1c=p1a; 0.upto(d1b){|i| p1c.array[i]+=p1b.array[i]}
	end;
	if d2b>=d2a; p2c=p2b; 0.upto(d2a){|i| p2c.array[i]+=p2a.array[i]}
	else p2c=p2a; 0.upto(d2b){|i| p2c.array[i]+=p2b.array[i]}
	end;
	d1c=p1c.degree; d2c=p2c.degree;
	if (d1c>=d2c); if (d2c>=d00); ab=p1c.timesSep(p2c,d1c,d2c); else ab=p1c.timesCnv(p2c); end;
	else if (d1c>=d00); ab=p2c.timesSep(p1c,d2c,d1c); else ab=p1c.timesCnv(p2c); end
	end
	ab=ab-(aa+bb);
	bb.array=bb.array+Array.new(d+d+2-bb.array.size,@zero)+aa.array
	0.upto(ab.degree){|i| bb.array[i+d+1]+=ab.array[i]}
	return bb.normalize!
end;


def * (other)
	if other.kind_of?(Polynomial)
		d1=self.degree; d2=other.degree; d00=25
		if (d1>=d2); if (d2>=d00); p=self.timesSep(other,d1,d2); else p=self.timesCnv(other); end
		else if (d1>=d00); p=other.timesSep(self,d2,d1); else p=self.timesCnv(other); end
		end;
		return p;
	elsif other.kind_of?(@one.class) or other.kind_of?(Numeric) 
		d=self.degree; a=Polynomial.new(@one,@one); a.array=Array.new(d+1)
		0.upto(d){|i| a.array[i]=@array[i]*other}
		return a.normalize!
	elsif other.kind_of?(RationalPoly)
		return RationalPoly(self)*other
	else x,y=other.coerce(self)
		return x*y
	end
end


def ** (power)
	if power.kind_of?(Integer)
		# calculate ** following to binary notation of "power".
		if (power>0);
			p=self.clone;p.normalize!;s=Polynomial.new([@one],@one)
			while power>0
				if power&1==1; s *= p;end
				p=p*p; power >>= 1
			end
		else
			return Polynomial(@one)
		end
	elsif power.kind_of?(Rational)||power.kind_of?(Float)
		return self**(power.to_i)
	else raise TypeError
	end
	return s
end

def powerModI (power, m, n=0)
	# self^power mod m(poly.)
	# coefficient modulo n, if n>0. 
	if power.kind_of?(Integer) and power>=0
		if n==0;
			# calculate ** following to binary notation of "power".
			p=self.modI(m); s=Polynomial.new([@one],@one)
			while power>0
				if power&1==1; s = (s*p).modI(m);end
				p=(p*p).modI(m); power >>= 1
			end
			return s
		else
			# calculate ** following to binary notation of "power".
			p=self.modI(m).coeff_to_Zp(n); s=Polynomial.new([@one],@one)
			while power>0
				if power&1==1; s = (s*p).modI(m).coeff_to_Zp(n);end
				p=(p*p).modI(m).coeff_to_Zp(n); power >>= 1
			end
			return s
		end;
	else raise TypeError
	end
end



def divmod(divisor) # assume that coefficient is field.
	if divisor.kind_of?(Polynomial)
		r=self.clone; degR=r.degree # Remainder(dividend)
		degD=divisor.degree; topD=divisor.array[degD]; # Divisor
		degQ=degR-degD; if degQ<0;degQ=0;end
		q=Polynomial.new(@zero,@one); q.array[0..degQ]=@zero #Quotient
		while degR>=degD
			if r.array[degR]==@zero;  q.array[degR-degD]=@zero
			else
				q1=Number.divII(r.array[degR],topD)
				dq=degR-degD; q.array[dq]=q1
				for i in (0..degD-1); r.array[i+dq] -= divisor.array[i]*q1; end
				r.array[degR]=@zero; # if field
				# r.array[degR] -= divisor.array[degD]*q1; # otherwise
			end;
			degR -= 1
		end
		return q.normalize!,r.normalize!
	elsif divisor.kind_of?(Numeric)
		q=self.clone
		q.array.each_with_index{|c,i| q.array[i]=Number.divII(c,divisor)}
		return q.normalize!,Polynomial(@zero,@one)
	else
		return self.divmod(Polynomial(divisor))
	end
end

def divmodR(divisor) # assume that coefficient is not field.
	if divisor.kind_of?(Polynomial)
		r=self.clone; degR=r.degree # Remainder(dividend)
		degD=divisor.degree; topD=divisor.array[degD]; # Divisor
		degQ=degR-degD; if degQ<0;degQ=0;end
		q=Polynomial.new(@zero,@one); q.array[0..degQ]=@zero #Quotient
		while degR>=degD
			if r.array[degR]==@zero;  q.array[degR-degD]=@zero
			else
				q1=r.array[degR]/topD
				dq=degR-degD; q.array[dq]=q1
				for i in (0..degD-1); r.array[i+dq] -= divisor.array[i]*q1; end
				# r.array[degR]=@zero; # if field
				r.array[degR] -= divisor.array[degD]*q1; # otherwise
			end;
			degR -= 1
		end
		return q.normalize!,r.normalize!
	elsif divisor.kind_of?(Numeric)
		q=self.clone
		q.array.each_with_index{|c,i| q.array[i]=Number.divII(c,divisor)}
		return q.normalize!,Polynomial(@zero,@one)
	else
		return self.divmod(Polynomial(divisor))
	end
end


def div(other)
q,r=self.divmod(other)
return q
end

alias / div

def mod(other)
q,r=self.divmod(other)
return r
end

alias % mod 

def modI(divisor)
	if divisor.lc==@one;
		r=self.clone; degR=r.degree # Remainder(dividend)
		degD=divisor.degree; # Divisor. Assume that lc==1
		while degR>=degD
			q1=r.array[degR]
			if q1==@zero;#  q.array[degR-degD]=@zero
			else
				dq=degR-degD;
				0.upto(degD){|i|
					r.array[i+dq] -= divisor.array[i]*q1;
				}
			end
			degR -= 1
		end
		if r.array.size>degD; r.array=r.array[0..degD-1]; end;
		return r.normalize!
	end;
	q,r=self.divmodI(divisor); return r;
end;

def divI(divisor)
	q,r=self.divmodI(divisor); return q;
end;

def divmodI (divisor)
# Coefficients of quotient allow only Integer.
# Note that degree of remainder can be greater than divisor.
	if divisor.kind_of?(Polynomial)
		if divisor.zero?;
			return Poly(@zero),self.clone;
		end;
		r=self.clone; degR=r.degree # Remainder(dividend)
		degD=divisor.degree; topD=divisor.array[degD] # Divisor
		degQ=degR-degD; if degQ<0;degQ=0;end
		q=Polynomial.new(@zero,@one); q.array[0..degQ]=@zero #Quotient
		while degR>=degD
			if r.array[degR]==@zero;  q.array[degR-degD]=@zero
			else
				q1=Number.divFloor(r.array[degR],topD)
				dq=degR-degD; q.array[dq]=q1
				if q1 != @zero;
					for i in (0..degD);
						r.array[i+dq] -= divisor.array[i]*q1;
					end
				end
			end
			degR -= 1
		end
		return q.normalize!,r.normalize!
	else
		return self.divmodI(Polynomial(divisor))
	end
end


def modZp (divisor,p)
	q,r=self.divmodZp(divisor,p); return r
end;
def divZp (divisor,p)
	q,r=self.divmodZp(divisor,p); return q
end;

def divmodZp (divisor,p)
# Divide over Zp. Assume that coefficients are Integer.
	if divisor.kind_of?(Polynomial)
		r=self.clone; degR=r.degree # Remainder(dividend)
		dv=divisor.coeff_to_Zp(p);
		degD=dv.degree; topDr=Number.inv(dv.array[degD],p) # Divisor
		degQ=degR-degD; if degQ<0;degQ=0;end
		q=Polynomial.new; q.array[0..degQ]=0 #Quotient
		while degR>=degD
			if r.array[degR]==0;  q.array[degR-degD]=0
			else
				q1=Number.modP(r.array[degR]*topDr,p)
				dq=degR-degD; q.array[dq]=q1;
				if q1 != 0;
					q1=(p-q1)%p
					for i in (0..degD-1); r.array[i+dq] += dv.array[i]*q1; end
				end
			end
			r.array[degR]=0; degR -= 1
		end
		return q.normalize!.coeff_to_Zp(p),r.normalize!.coeff_to_Zp(p)
	else
		return self.divmodZp(Polynomial(divisor),p)
	end
end


def derivative(n=1)
p=self.clone; p=p.normalize!
n.times{p.array.each_index{|i| p.array[i] *= i};p.array.shift}
return p.normalize!
end


def integral(n=1)
p=self.clone; p=p.normalize!
n.times{
	p.array.each_with_index{|v,i| p.array[i]=Number.divII(v,i+1)}
	p.array.unshift(0)
}
return p
end


def substitute(x=0)
i=self.degree; s=0;
while i>=0;s= (x*s)+@array[i]; i -= 1;end; return s
#              ^^^ Dn't s*x to conform to type of x.
end

def substitute_reverse(a=1,m=0)
	# (self*(a^(degree))).substitute(x/a) (mod m)
	# e.g. x^3 + x^2 + x + 1 --> x^3 + a x^2 + a^2 x + a^3
	if m==0 then
		r=self.clone; d=degree-1; p=a;
		while(d>=0); r[d]*=p; p=p*a; end;
		return r
	else
		r=self; d=degree-1; p=a%m;
		while(d>=0); r[d]*=p; p=(p*a)%m; d=d-1; end;
		return r.coeff_to_Zp(m)
	end;
end;

def <=> (other)
	if other.kind_of?(Polynomial)
		d0=self.degree; d1=other.degree
		if d0==d1;
			for i in (0..d0)
				v0=@array[d0-i]; v1=other.array[d0-i];
				if v0 != v1; return v0<=>v1;end
			end
		end
		return d0<=>d1
	else
		return self<=>Polynomial(other)
	end
end

def ==(other)
	return (self-other).zero?
end

def to_a
return @array
end

def coerce(x)
	case x
	when Numeric; return Polynomial(x), self
	when String; return Polynomial(x), self
	when Array; return Polynomial(x), self
	else ; raise TypeError
	end
end


def lcm_coeff_denom # lcm of denominator of coefficients as Rarional
den=[1]
@array.each{|c| if c.kind_of?(Rational); den.push(c.denominator.abs);end}
return Number.lcm(den)
end

def gcd_coeff_num # gcd of numerator coefficients as Rational
num=[]
@array.each{|c|
	if c.kind_of?(Rational)||c.kind_of?(Integer); num.push(c.numerator.abs);end
}
if num.empty?;return 1; else return Number.gcd(num);end
end

def coeff_to_real
f=Polynomial.new
@array.each_with_index{|i,v|
	if v.kind_of?(Complex); f[i]=v.real; else f[i]=v; end
}
return f
end

def coeff_to_Z
#       Get Z-coefficient polynomial from Rational-coefficient polynomial
#       with multiply a Rational.
f=self*self.lcm_coeff_denom; f=f/f.gcd_coeff_num; f=f.coeff_truncate; return f
end

def coeff_truncate # truncate each coefficient to Integer
f=self.clone; f.array.each_with_index{|x,i| f.array[i]=x.truncate}; return f
end

def coeff_round # round each coefficient to Integer
f=self.clone; f.array.each_with_index{|x,i| f.array[i]=x.round}; return f
end

def coeff_to_f # converts each element to Float
f=self.clone; f.array.each_with_index{|x,i| f.array[i]=x.to_f}; return f
end

def coeff_to_Zp(prime, positive=true)
	p=Polynomial.new
	if positive;
		@array.each_with_index{|x,i| p.array[i]=Number.modP(x,prime)}
	else
		n=0; p2=prime.div(2)
		@array.each_with_index{|x,i| n=Number.modP(x,prime);
			if p2<n;n=n-prime;end
			p.array[i]=n
		}
	end
	p.normalize!
	return p
end

def coeffR_to_Zp(prime)
	p=Polynomial.new
	@array.each_with_index{|x,i| p.array[i]=Number.rmodP(x,prime)}
	p.normalize!
	return p
end


def to_s(format="text",v="x", r=true)
	# return @array.join(":")
	# v: variable, r: switch of order
    case format
    when "text"; timeS="";power1="^(";power2=")"; ms=""; me=""
    when "tex"; timeS="";power1="^{";power2="}"; ms=""; me=""
    when "texm"; timeS="";power1="^{";power2="}"; ms="$"; me="$"
    when "prog"; timeS="*"; power1="**(";power2=")"; ms=""; me=""
    end
	s=""
	deg=self.degree; addS=""
	for i in (0..deg);  if r; d=deg-i;else d=i;end
		c=@array[d]
		if c != 0;
			if c<0;s=s+"-";c=-c;else; s=s+addS;end;
			addS="+"
			if c.kind_of?(Rational)&&(c.denominator != 1);
				den="/"+c.denominator.to_s; c=c.numerator
			else
				den=""
			end
			if (c != 1)||(d == 0); s=s+(c.to_s);end;
			if (c != 1)&&(d != 0); s=s+timeS;end
			if d != 0; s=s+v;
				if d != 1; s=s+power1+(d.to_s)+power2;end
			end
			s=s+den
		end
	end
	if s==""; s="0";end
	s=ms+s+me # math start and math end
	return s
end


def Polynomial.gcdS(a,b)
while true
	if b.zero?; return a;end
	q,a=a.divmod(b)
	if a.zero?; return b;end
	q,b=b.divmod(a)
end
end

def Polynomial.gcd(a,*b) # wrpper of gcdS
case a
when Array;
when Polynomial; a=[a]+b
else  raise TypeError
end
g=Polynomial(0); a.each{|x| g=gcdS(x,g)}
return g
end


def Polynomial.lcm(a,*b)
case a
when Array;
when Polynomial; a=[a]+b
else  raise TypeError
end
l=Polynomial(1); a.each{|x| l=l*x.div(gcdS(l,x))}
return l
end


def Polynomial.gcd2s(a,b)
	x=Polynomial(1); v=x.clone
	y=Polynomial(0); u=y.clone
	while true
		if b.zero?; return a,x,y; end
		q,a=a.divmod(b); x=(x-q*u); y=(y-q*v)
		if a.zero?; return b,u,v; end
		q,b=b.divmod(a); u=(u-q*x); v=(v-q*y)
	end
end


def Polynomial.gcd2(a,*b) # wrapper of gcd2s
# return gcd, *xj, s.t. gcd=a[0]*xj[0]+a[1]*xj[1]+...+a[n]*xj[n]
case a
when Array;
when Polynomial; a=[a]+b
else  raise TypeError
end
	g=Polynomial(0); xj=[]; # gcd up to i
	a.each{|b|
		g,x,y=gcd2s(b,g)
		xj.each_index{|j| xj[j]=xj[j]*y}
		xj.push(x)
	}
	return g,*xj
end



def Polynomial.gcdSZp(prime,a,b)
b=b.coeff_to_Zp(prime)
while true
	if b.zero?; return a;end
	q,a=a.divmodZp(b,prime)
	if a.zero?; return b;end
	q,b=b.divmodZp(a,prime)
end
end

def Polynomial.gcdZp(prime,a,*b) # wrpper of gcdSZp
case a
when Array;
when Polynomial; a=[a]+b
else  raise TypeError
end
g=Polynomial(0); a.each{|x| g=gcdSZp(prime,x,g)}
return g
end

def Polynomial.gcd2sZp(prime,a,b)
	a=a.coeff_to_Zp(prime)
	b=b.coeff_to_Zp(prime)
	x=Polynomial(1); v=x.clone
	y=Polynomial(0); u=y.clone
	while true
		if b.zero?; return a,x,y; end
		q,a=a.divmodZp(b,prime);
		x=(x-q*u).coeff_to_Zp(prime); y=(y-q*v).coeff_to_Zp(prime)
		if a.zero?; return b,u,v; end
		q,b=b.divmodZp(a,prime); 
		u=(u-q*x).coeff_to_Zp(prime); v=(v-q*y).coeff_to_Zp(prime)
	end
end

def Polynomial.gcd2Zp(prime,a,*b) # wrapper of gcd2sZp
# return gcd, *xj, s.t. gcd=a[0]*xj[0]+a[1]*xj[1]+...+a[n]*xj[n]
case a
when Array;
when Polynomial; a=[a]+b
else  raise TypeError
end
	g=Polynomial(0); xj=[]; # gcd up to i
	a.each{|b|
		g,x,y=gcd2sZp(prime,b,g)
		xj.each_index{|j| xj[j]=(xj[j]*y).coeff_to_Zp(prime)}
		xj.push(x)
	}
	return g,*xj
end

def getSPolyZ(g)
	fd=self.degree; fc=self.lc
	gd=g.degree; gc=g.lc
	degx=[fd,gd].max; gcd=Number.gcd(fc.abs,gc.abs); # lcm=fc*gc/gcd
	h=Polynomial.term(gc.div(gcd),degx-fd)*self-Polynomial.term(fc.div(gcd),degx-gd)*g
	return h
end

def getSturm # return  GCD, Sturm_sequence
	sturm=[];  sturm.push(self.clone);  sturm.push(self.derivative)
	while ! sturm[-1].zero?;  sturm.push(-(sturm[-2].mod(sturm[-1])));  end
	sturm.pop; gcd_s=sturm[-1].clone
	for i in 0..sturm.size-1;  sturm[i]=sturm[i].div(gcd_s);  end
	return gcd_s, sturm
end

def countSturmChange(a,sturm)
	sturmA=[];
	sturm.each{|p|
		if a==Infinity;sturmA.push(p.lc)
		elsif a==-Infinity;
			if p.degree&1==1; sturmA.push(-p.lc); else sturmA.push(p.lc); end;
		else pa=p.substitute(a); if pa!=@zero; sturmA.push(pa); end;
		end
	}
	v=0 #  #of sign change
	for i in 0..sturmA.size-2; if (sturmA[i]>0)!=(sturmA[i+1]>0); v=v+1;end;  end
	return v
end

def countSolution(a=-Infinity,b=Infinity, countRedundancy=true)
	#     count # of solution between a and b using Sturm algorithm.
	#     a and b be Integer,Rational,Float, "-infty" or "infty"
	if (a==Infinity)||(b==-Infinity); return 0
	elsif (a==-Infinity)||(b==Infinity);
	elsif a.kind_of?(Numeric)&&b.kind_of?(Numeric)&&(a>=b); return 0
	end
	if a.kind_of?(Numeric) and substitute(a)==0 then 
		return (self/Polynomial.new([-a,1],1)).countSolution(a,b,countRedundancy);
	end;
	if b.kind_of?(Numeric) and substitute(b)==0 then 
		return (self/Polynomial.new([-b,1],1)).countSolution(a,b,countRedundancy);
	end;
	gcd_s,sturm = self.getSturm
	if (countRedundancy)&&(gcd_s.degree>0); n1=gcd_s.countSolution(a,b);
	else n1=0;
	end
	return countSturmChange(a,sturm)-countSturmChange(b,sturm)+n1
end


def squareFreeDecomposition
g=[self.clone]
while g[-1].degree>0; gm=g[-1].clone; g.push(Polynomial.gcd(gm, gm.derivative)); end
h=[Poly(1)]; i=1;
while i<g.size; h[i]=g[i-1]/g[i]; i=i+1; end
h.push(Poly(1))
f=[Poly(1)]; i=1
while (i+1)<h.size; f[i]=(h[i]/h[i+1]).coeff_to_Z; i=i+1; end
return f
end


def SqrFree?(prime=0)
if prime==0;gcd=Polynomial.gcd(self,self.derivative)
else gcd=Polynomial.gcdZp(prime,self,self.derivative)
end
return (gcd.degree==0)
end


def Polynomial.constructionHensel(f,g,h,n,prime,pn)
d0=f-g*h; d=(d0/pn).coeff_to_Zp(prime)
gcd,a0,b0=Polynomial.gcd2Zp(prime,[g,h]);
a1=(a0*d*Number.inv(gcd.array[0],prime))
b1=(b0*d*Number.inv(gcd.array[0],prime))
# Must be a1.degree<h.degree, b1.degree<=g.degree.
q,a=a1.divmodZp(h,prime)
b=(b1+q*g).coeff_to_Zp(prime)
g1=(g+b*pn).coeff_to_Zp(pn*prime,false)
h1=(h+a*pn).coeff_to_Zp(pn*prime,false)
# Now, a*g1+b*h1==d mod prime and f==g*h mod prime^(n+1)
return g1,h1
end


def factorize
	return Factorization.factorize(self)
end

def Polynomial.factor2s(f,s="")
if s==""; return "("+Number.factor2s(f,")(")+")"
else return Number.factor2s(f,s)
end
end


module Factorization
# Factorize a polynomial
#	Let  p:prime.
#(1) Let Ap be A in Zp<t>.
#	if Ap=1 ;  Apd:=1; Resume. 
#(2) Search  A'p s.t.  A'p | Apd in Zp.
#(3)	Check of A' | A in Z[t]
#
# Zp 上での因子の推定を2種
# Zp上の因子から Z上の因子の構成を 2種 持っており
# 扱う次数によって切替えて使用している.


### as module variables ###
Factor=[]
PolyN=Polynomial.new # Normalized
PolyM=Polynomial.new # PolyN in Zp
DpolyM=Polynomial.new #  divisor in Zp i.e.  DpolyM|PolyM
DpolyMs=Polynomial.new # change each coefficient to little abs
TblS=[] # work table
V0=[]; V1=[]; V1nS=[]




def  checkDivZp (dividend,divisor,prime) # true if divisible in Zp
# q,r=dividend.divmodZp(divisor,prime); return r.zero?
degR=dividend.degree 
degD=divisor.degree
if degR < degD
	return false
end
darray=divisor.array
rarray=dividend.array.clone # Remainder(dividend)
topDm=prime-Number.inv(darray[degD],prime) #   -1/divisor.lc
while degR>=degD
	q1=(rarray[degR]*topDm)%prime;
	if q1 != 0;
		dq=degR-degD
		for i in (0..degD-1)
			rarray[i+dq] += darray[i]*q1
		end
	end
	degR -= 1
end
for i in (0..degD-1)
	if (rarray[i] % prime) != 0
		return false
	end
end
return true
end


##### expand DpolyMs to Z-coefficient witn Hensel's construction #######


def setgL1(g)
l=0; g.array.each{|c| l=l+c.abs}; return l
end

def  setPolyRHensel(prime)
f=PolyN.clone
if f.lc<0;
	f.array.each_index{|i| f[i]=-f[i]}
end
g=DpolyMs.clone
# make f monic
lc=f.lc.to_i
f=f.substitute_reverse(lc)/lc; # f=(f*(Number.powerI(lc,f.degree-1))).substitute(Poly("x")/lc)
# g=(g*(Number.powerI(lc,g.degree)*Number.inv(g.lc,prime)))
# g=g.substitute(Poly("x")/lc).coeff_to_Zp(prime,false)
# g=g.coeff_to_Zp(prime,false)
g=(g*Number.inv(g.lc,prime)).substitute_reverse(lc,prime)
q,r=f.divmodI(g)
if r.zero?; 
	g=g.substitute(Poly("x")*lc).coeff_to_Z
	q,r=PolyN.divmodI(g)
	PolyN.array.replace(q.array); Factor.push(g);
	PolyM.array.replace(PolyN.coeff_to_Zp(prime).array);
	return true;
end
#if ! Number.checkDivZ?(f[0],g[0],prime); return false;end
h,r=f.divmodZp(g,prime)
### How to bound iteration ? ###
# F= fk x^k +...+f1 x^1+f0,  G= gl x^l +...+gx x^1+g0
# Let fL2= sqrt(|fk|^2+...+|f0|^2)* (gl/fk *2^l),  gL1= (|gl|+..+|g0|)
# then  gL1<= fL2. 
# Iterate until |max coefficient of g| < gL1 <= fL2 < pn/2.
# (Note thet f.lc==1, g.lg==1, pn=prime^n)
# Let fMax=(max coefficient of f).
# Check if divisible when  pn^n>fMax,
fL2=1; fMax=0;
f.array.each{|c| fL2=fL2+c*c; if fMax<c.abs;fMax=c.abs;end}
fL2=Number.sqrti(fL2*4**(g.degree))
###
n=1; pn=prime # pn=prime^n
gL1=setgL1(g)
while (pn<fL2*2)&&(gL1<=fL2)
	g,h=Polynomial.constructionHensel(f,g,h,n,prime,pn)
	n=n+1; pn=pn*prime
	if (pn>fMax)&&(f-g*h).zero?;
		g=g.substitute(Poly("x")*lc).coeff_to_Z
		q,r=PolyN.divmodI(g)
		PolyN.array.replace(q.array); Factor.push(g);
		PolyM.array.replace(PolyN.coeff_to_Zp(prime).array);
		return true;
	end
	gL1=setgL1(g)
end
return false
end


##### expand DpolyMs to Z-coefficient with simple try&error #####
# 因子に -PolyN.degree/4..PolyN.degree/4 の整数を
# 代入した値を推定して, 因子を構成する.
# degD=DpolyM.degree for almost part.

def  setPolyR(degD,prime)
# TRUE if Set  set polynomial PolyF[] from TblS[]
# From dPolyM in Zp[x], recover polyF in Z[x].
#local var: dv,dt,at, deg,diff,i, tbl0, tbl2
deg=degD
polyF=Polynomial.new
polyF.array.fill(0,0..degD)
tbl0=TblS.clone
while deg>=1
	tbl2=tbl0.clone
	dv=1;
	diff=deg
	while diff>=1
		for i in (0..diff-1); tbl2[i]=tbl2[i+1]- tbl2[i];end
		dv *= diff;
		diff -= 1
	end
	if ((tbl2[0] % dv) != 0); return false;end
	at=tbl2[0].div(dv);
	polyF.array[deg]=DpolyMs.array[deg]+at*prime;
	for i in (0..deg)
		dt=at;
		dv=i-(degD.div(2));
		for j in (1..deg); dt *= dv;end
		tbl0[i] -= dt;
	end
	deg -= 1
end
polyF.array[0]=DpolyMs.array[0]+tbl0[0]*prime
polyF.normalize!
return true,polyF
end


def setV0Tbl(degD) # table of PolyN. 
# Elements are non-zero, because PolyN has no factor (x-a) in this range
V0.clear; for i in (0..degD); V0[i]=PolyN.substitute(i-(degD.div(2))).abs; end
end

def setV1Tbl(degD) # table of DpolyMs
V1.clear; for i in (0..degD); V1[i]=DpolyMs.substitute(i-(degD.div(2))); end
end


def setVal(ite,degD,prime)
# Note that change PolyN and PolyM.
v0i=V0[ite]; v1i=V1[ite]; setFlg=false;
# (v1i+prime*a)|v0i then range of a is
# (-v0i-v1i)/prime..(v0i-v1i)/prime
a=0;
if a<(-v0i-v1i).div(prime); a=(-v0i-v1i).div(prime);end
if a>(v0i-v1i).div(prime); a=(v0i-v1i).div(prime);end
while ((-v0i-v1i).div(prime)<=a)&&(a<=(v0i-v1i).div(prime))
	v1n=(v1i+prime*a).abs;
	if ((v1n !=0) && ((v0i % v1n)==0)) ;
		V1nS[ite]=v1n
		TblS[ite]=a;
		if (ite>=degD);
			setFlg,polyF=setPolyR(degD,prime);
			if setFlg
				polyQ,polyR=PolyN.divmodI(polyF)
				if polyR.zero?
					#printf "M=%s F=%s prime=%d\n",DpolyMs.to_s,polyF.to_s,prime
					PolyN.array.replace(polyQ.array);
					PolyM.array.replace(PolyN.coeff_to_Zp(prime).array);
					Factor.push(polyF);
					# The polynomial is square free, so,
					# this is only one factor having DpolyMs
					throw(:setValTag,true);
					#return true
				end
			end
		else 
			if setVal(ite+1,degD,prime); return true;end
		end
	end
	if a<=0;a=1-a; if a>(v0i-v1i).div(prime); a=-a; end
	else    a=-a; if a<(-v0i-v1i).div(prime); a=1-a; end
	end 
end
return false
end



##### Expand DPolyM in Zp[x] to PolyM in Z[x] with PolyM|PolyN


def resume(prime) # TRUE if find Factors
# printf "resume: prime=%d, d=%s \n",prime, DpolyM
findFlg=false;
if DpolyM.degree>=5
	dz=DpolyM.coeff_to_Zp(prime,false)
	DpolyMs.array.replace(dz.array.clone)
	findFlg=setPolyRHensel(prime);
else
	i=1
	while i<prime
		# 頭項の因子を調整. PolyN,DpolyM が monic なら,これは不要.
		dpolym=(DpolyM*i).coeff_to_Zp(prime)
		if Number.checkDivZ?(PolyN.lc,dpolym.lc,prime)&&
				Number.checkDivZ?(PolyN[0],dpolym[0],prime);
			DpolyMs.array.replace(dpolym.coeff_to_Zp(prime,false).array)
			degD=DpolyM.degree
			TblS.clear; setV0Tbl(degD); setV1Tbl(degD)
			findFlg=(catch(:setValTag) do ;
					throw(:setValTag,setVal(0,degD,prime));
				end)
			#findFlg=setVal(0,degD,prime)
			if findFlg; return true;end
		end
		i=i+1
	end
end;
return findFlg;
end


# ----------------following PROCEDUREs work in Zp[t]-------------

# Note that the polynomial PolyN is square free in Zp


######### set DpolyM with Berlekamp's algorithm ########
# DpolyM | PolyN over Zp

def printQ(q)
n=q.size
print "["
for i in 0..q.size-1; for j in 0..q[i].size-1
	printf "%2d ",q[i][j]
end; print "\n"; end
print "]\n"
end


def getQ(f,prime)
q=[]
n=f.degree
w1=(Poly("x")**prime);
w3,w1=w1.divmodZp(f,prime)
w2=Poly("1")
q=[]
for i in 0..n-1
	a=[].fill(0,0..n-1)
	w2.array.each_with_index{|c,j| a[j]=c}
	q[i]=a.clone
	w3,w2=(w2*w1).divmodZp(f,prime)
end
return q
end


def solveQ1(q,prime)
n=q.size
q0=[]
for i in 0..n-1
	q0[i]=q[i].clone
end
for i in 0.. n-1
	q[i][i]=(q[i][i]+prime-1)%prime
end
#printQ(q)
pivot=[].fill(-1,0..n-1)
for i in 0..n-1
	# set pivot
	j1=0; while (j1<n)&&((q[i][j1] == 0)||(pivot[j1] != -1)); j1=j1+1;end
	if j1<n;
		for i1 in i..n-1; q[i1][j1],q[i1][i]=q[i1][i],q[i1][j1]; end
		pivot[i]=i; j=i
		pvr=Number.inv(q[i][j],prime)
		for j1 in 0..n-1;
			if j1 != j
				d=((prime-q[i][j1])*pvr)%prime
				for i1 in 0..n-1; 
					q[i1][j1]= (q[i1][j1]+d*q[i1][j])%prime
				end
			end
		end
	end
end
solve=[]
for i in 0..n-1
	if pivot[i]==-1
		v=[].fill(0,0..n-1)
		v[i]=1
		for j in 0..n-1
			v[j]=(v[j]+prime-(q[i][j]*Number.inv(q[j][j],prime))%prime)%prime;
		end
		u=Poly("0");x=Poly("x")
		for j in 0..n-1; xj=x**j; for k in 0..n-1;
			u=u+xj*v[k]*q0[k][j]
		end;end
		solve.push(u.coeff_to_Zp(prime))
	end
end
return solve
end


def genFactors(f,uList,prime)
gcdList1=[];
uList.each{|u| 
	for i in 0..prime-1;
		g=Polynomial.gcdZp(prime, f,u+i);
		if g.degree>0; gcdList1.push(g);end
	end
}
i=0; changeFlg=false
while i<gcdList1.size-1
	gcdList1.sort!{|f1,f2| f1<=>f2}
	j=i+1; changeFlg=false
	while j<gcdList1.size
		q,r=gcdList1[j].divmodZp(gcdList1[i],prime)
		if r.zero?; changeFlg=true
			if q.degree>0;gcdList1[j]=q; j=j+1
			else gcdList1.delete_at(j);
			end
		else j=j+1
		end
	end
	if changeFlg; i=0;else i=i+1;end
end;
#printf "gcdList1:\n"; gcdList1.each{|f|printf "%s\n",f}
for i in 0..gcdList1.size-1
	g=gcdList1[i]
	gcdList1[i]=(g*Number.inv(g.lc,prime)).coeff_to_Zp(prime)
end
return gcdList1
end


FactorP=[] # factors in Z/(prime)Z

def setPolyB(depth,dpoly,prime)
	if depth<FactorP.size
		if setPolyB(depth+1,dpoly,prime);
			if ! dpoly==Poly("1");return true;end
		end
		if depth==0
			if PolyN.degree>0
				Factor.push(PolyN.clone); PolyN.array.replace([1]);
			end
			return true
		else
			dpoly=dpoly*FactorP[depth]
			if setPolyB(depth+1,dpoly,prime);
				FactorP.delete_at(depth);return true;
			end
			return false
		end
	else
		if dpoly.degree>0;
			DpolyM.array.replace(dpoly.coeff_to_Zp(prime).array);
			#DpolyMs.array.replace(dpoly.coeff_to_Zp(prime,false).array)
			#print "setPolyB: call resume. DpolyM="+DpolyM.to_str;
			return resume(prime) # TRUE if find Factors
		end
	end
end

def setPolyBerlekamp(prime)
f=PolyM.coeff_to_Zp(prime) 
#printf "PolyM: %s\n",PolyM
q=getQ(f,prime) 
# printQ(q)
uList=solveQ1(q,prime)
#printf "uList:%s\n",uList.join(", ")
factors=genFactors(f,uList,prime) 
#printf "factors:%s\n", factors.join(", ")
FactorP.replace(factors) 
#printf "FactorP:%s\n", FactorP.join(", ")
setPolyB( 0, Poly("1"), prime )
end


######### set DpolyM with simple try&error ###########
# DpolyM | PolyN over Zp


def checkZp(i,prime)
if PolyN.degree<DpolyM.degree*2;return true;end
return checkDivZp(PolyM,DpolyM,prime) && resume(prime)
end


def setPoly2(d,prime,degD)
i=0; c=(prime.div(2)).to_i
while true
	DpolyM[d]=i
	if (d<=0);
		if (i>0)&&checkZp(i,prime)&&(PolyN.degree<degD*2);
			throw(:setPolyTag)
		end
	else 
		setPoly2(d-1,prime,degD)
	end
	if i<=c;i=prime-i-1; if i==c;return;end; else i=prime-i; end
end
end

def setPoly(d,prime)
for degD in 1..d
	DpolyM[degD]=1  # Set DpolyM as monic.
	if (PolyN.degree<degD*2);throw(:setPolyTag);end
	setPoly2(degD-1,prime,degD)
end
end


########## factorize a square free polynomial #########

def factorizeSqrFree(p)
Factor.clear
PolyN.array.replace(p.coeff_to_Z.array)
if PolyN[0]==0; PolyN.array.shift;Factor.push(Polynomial([0,1]));end;
degN=PolyN.degree
i=1;
while (i<=degN)&&(i<=PolyN[0].abs)
	while (PolyN[0]%i==0)&&(0==PolyN.substitute(i).abs);
		polyF=Polynomial([-i,1])
		Factor.push(polyF)
		poly,polyR=PolyN.divmodI(polyF)
		PolyN.array.replace(poly.array)
		degN=PolyN.degree
	end
	if i>0;i=-i;else i=1-i;end
end

if degN==1;Factor.push(PolyN); return Factor
elsif degN==0; return Factor
end

# From here, we can assume that the polynmial has no factor (x-a), |a|<=degN/4

# With setPoly and setVal/setPolyR,
# time order for setPoly may be 
#     ~ k*prime^(degN/2)  , k=?
# time order for setVal
#     ~ l*(2fp/prime)^(degN/2),  l=?
#       fp=geometric mean of f(x) (x in (-degN/4..degN/2-degN/4))
# x=prime, d=degN,
# Assume that O(x)= kx^(d/2)+ l(2fp/x)^(d/2)
# O  is minimal at x=(l/k)^{1/d} (2v)^{1/2}

fp=1.0
for x in (-degN.div(4))..(degN.div(2)-degN.div(4)); fp *= PolyN.substitute(x).abs; end
fp=fp**(1.0/(degN.div(2)+1))
fp=Math.sqrt(fp/30.0).to_i
prime=Number.nextPrime(fp-1)
#printf "Set prime = %d, PolyN=%s\n",prime,PolyN.to_s

# serach prine s.t. leading coefficient and bottom coefficient does not vanish,
# and square free over Zp
head=PolyN.lc.abs; tail=PolyN[0].abs;
while (prime<=3)||(head%prime==0)||(tail%prime==0)||(! PolyN.SqrFree?(prime))
	prime=Number.nextPrime(prime)
end
# printf "Set prime = %d, PolyN=%s\n",prime,PolyN.to_s

PolyM.array.replace(PolyN.coeff_to_Zp(prime).array);
# Switch algorithms according to degree of the polynomial.
if PolyN.degree< 11
	# setPolyBerlekamp(prime)
	DpolyM.array.clear
	catch(:setPolyTag) do; setPoly(degN.div(2),prime);end
else
	DpolyM.array.clear
	catch(:setPolyTag) do; setPoly(3,prime);end
	if PolyN.degree<10
		DpolyM.array.clear
		catch(:setPolyTag) do; setPoly(PolyN.degree.div(2),prime);end
	else setPolyBerlekamp(prime)
	end
end
if (PolyN.degree>0); Factor.push(PolyN);end

# Make leading coefficients positive.
Factor.each{|p| if p.lc<0;p.array.each_index{|i| p[i]=-p[i]};end}
Factor.sort!{|f1,f2| f1<=>f2}
return Factor
end


########### factorize a polynomial #########

def factorize(p) # wrapper of factorizeSqrFree(p)
sqrF=p.coeff_to_Z.squareFreeDecomposition
factorA=[]
sqrF.each_with_index{|f,i| 
	if f.degree>0; ff=factorizeSqrFree(f);
		i.times{ ff.each{|ffc| factorA.push(ffc.clone)}};
	end;
}
factorA.sort!{|f1,f2| f1<=>f2}
return factorA
end


module_function :factorize, :factorizeSqrFree
module_function :checkZp,:checkDivZp
module_function :setVal,:setPolyR,:setV0Tbl,:setV1Tbl
module_function :setPolyRHensel, :setgL1
module_function :resume
module_function :setPoly,:setPoly2
module_function :getQ,:printQ,:solveQ1,:genFactors,:setPolyB,:setPolyBerlekamp

end # module  Factorization

end # class Polynomial
