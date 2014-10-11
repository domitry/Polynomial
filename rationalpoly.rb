# RationalPoly
#
############################################
# K.Kodama 2000/02/05
#
# Based on rational.rb by Keiju ISHITSUKA(SHL Japan Inc.)
#
# This module is distributed freely in the sence of 
# Ruby's License.
############################################
# --
#   Usage:
#   class RationalPoly
#
#   RationalPoly(a, b) or RPoly(a, b) --> a/b
#       a,b admit Numeric,Polynomial 
#       and String of polynomial.
#   +, -, *, /, **, %, divmod
#   abs
#       Make leading coefficients of numerator and denominator  positive.
#  derivative(n=1)
#       n-th derivative
#  substitute(x)
#   reduce, reduce!
# CONVERTING:
#   approx(deg=false)
#       convert from rational polynomial to Taylor's approximation.
#       if deg is Integer then use it,
#       else numerator.degree + denominator.degree*2
#   to_poly
#       return quitient of numeretor/denominator
#   to_approx_poly(deg)
#       polynomial approximation
#   to_s
#   coeff_to_Z
#       Rational又はInteger係数の場合, 有理数で約分して, 整数係数にする.
#       Bugs.
#          Float, Complex 係数の動作は保証しない.
# TESTING:
#   ==
#   zero?
#   <=>

require "polynomial"
require "rational"

def RationalPoly(a, b = Polynomial(1))
	if a.kind_of?(RationalPoly)
		if b==1; return a;
		elsif b.kind_of?(RationalPoly)
			if b.zero?; raise ZeroDivisionError, "denometor is 0" ;end
			return a/b
		else
			b=Polynomial(b)
			if b.zero?; raise ZeroDivisionError, "denometor is 0" ;end
			return a/RationalPoly.new(b)
		end
	end
	a=Polynomial(a)
	if b.kind_of?(RationalPoly)
		if b.zero?; raise ZeroDivisionError, "denometor is 0" ;end
		return RationalPoly.new(a)/b
	end
	b=Polynomial(b)
	if b.zero?; raise ZeroDivisionError, "denometor is 0" ;end
    return RationalPoly.new(a, b)
end

alias RPoly RationalPoly

class RationalPoly

def zero?
	return @numerator.zero?
end

def reduce
	den=@denominator.clone; num=@numerator.clone
	if den.lc < 0; num = -num;  den = -den; end
	gcd = Polynomial.gcd(num,den)
	num,r = num.divmod(gcd);  den,r = den.divmod(gcd)
	l=Number.lcm(num.lcm_coeff_denom,den.lcm_coeff_denom)
	num=num*l; den=den*l
	g=Number.gcd(num.gcd_coeff_num,den.gcd_coeff_num)
	num=num/g; den=den/g
	if den.unit?
		return RationalPoly.new(num,den)
		# return num/den # As a PolynomialM.
	else
		return RationalPoly.new(num, den)
	end
end

def reduce!
v=self.reduce
@numerator=v.numeretor; @denominator=v.denominator
return v
end

def initialize(num, den=Polynomial(1))
	den = Polynomial(den); num = Polynomial(num)
	# if den.zero?; raise ZeroDivisionError, "denometor is 0" ;end
	if den.lc < 0; num = -num; den = -den;end
	@numerator = num; @denominator = den
end

private :initialize

attr_accessor :numerator
attr_accessor :denominator

def clone
	den = @denominator.clone; num=@numerator.clone
	return RationalPoly.new(num,den)
end

def -@
return RationalPoly(-@numerator, @denominator)
end


def + (a)
	if a.kind_of?(RationalPoly)
		num = @numerator * a.denominator
		num_a = a.numerator * @denominator
		return RationalPoly(num + num_a, @denominator * a.denominator)
	elsif a.kind_of?(Numeric)
		return self + RationalPoly.new(a)
	elsif a.kind_of?(Polynomial)
		return self + RationalPoly.new(a)
	else
		x , y = a.coerce(self)
		return x + y
	end
end
  
def - (a)
	return self+(-a)
end

def * (a)
	if a.kind_of?(RationalPoly)
		num = @numerator * a.numerator
		den = @denominator * a.denominator
		return RationalPoly.new(num, den)
	elsif a.kind_of?(Polynomial)
		num = @numerator * a
		den = @denominator
		return RationalPoly.new(num, den)
	elsif a.kind_of?(Numeric)
		num = @numerator * Polynomial.new(a)
		den = @denominator
		return RationalPoly.new(num, den)
	else
		x , y = a.coerce(self)
		return x * y
	end
end
  
def / (a)
	if a.kind_of?(RationalPoly)
		if a.zero?; raise ZeroDivisionError, "denometor is 0" ;end
		num = @numerator * a.denominator
		den = @denominator * a.numerator
		return RationalPoly.new(num, den)
	elsif a.kind_of?(Numeric)
		if a==0; raise ZeroDivisionError, "denometor is 0" ;end
		num = @numerator
		den = @denominator * Polynomial(a)
		return RationalPoly.new(num, den)
	elsif a.kind_of?(Polynomial)
		if a.zero?; raise ZeroDivisionError, "denometor is 0" ;end
		num = @numerator
		den = @denominator * a
		return RationalPoly.new(num, den)
	else
		x , y = a.coerce(self)
		return x / y
	end
end
  
def ** (other)
	if other.kind_of?(Integer)
		if other > 0
			num = @numerator ** other
			den = @denominator ** other
		elsif other < 0
			num = @denominator ** (-other)
			den = @numerator ** (-other)
		elsif other == 0
			num = Polynomial(1)
			den = Polynomial(1)
		end
		return RationalPoly.new(num, den)
	else
		x , y = other.coerce(self)
		x ** y
	end
end

def divmod(other)
	v = (self / other)
	q,r= v.numerator.divmod(v.denominator)
	return q, self-other*q
end

def % (other)
	q,r=self.divmod(other)
	return r
end

def abs
	num=@numerator.clone; if num.lc<0; num=-num;end
	den=@denominator.clone; if den.lc<0; den=-den;end
	return RationalPoly.new(num,den);
end


def derivative(n=1)
num=@numerator; den=@denominator
n.times{
	num=num.derivative*den - num*den.derivative
	den=den*den
}
return RationalPoly(num,den).reduce
end

def <=>(a)
if a.kind_of?(RationalPoly)
	if (@denomiinator>=0)==(a.denominator>=0);
		return ((@numerator * a.denominator)<=>(a.numerator * @denominator))
	else
		return ((a.numerator * @denominator)<=>(@numerator * a.denominator))
	end
elsif a.kind_of?(Numeric)
	if (@denomiinator>=0);
		return (@numerator <=> (@denominator*a))
	else
		return ((@denominator*a) <=> @numerator)
	end
elsif a.kind_of?(Polynomial)
	if (@denomiinator>=0);
		return (@numerator <=> (@denominator*a))
	else
		return ((@denominator*a) <=> @numerator)
	end
else
	x , y = a.coerce(self)
	return (x <=> y)
end
end

def ==(a)
if a.kind_of?(RationalPoly)
	return (@numerator * a.denominator)==(a.numerator * @denominator)
elsif a.kind_of?(Numeric)
	return @numerator == @denominator*a
elsif a.kind_of?(Polynomial)
	return @numerator == @denominator*a
else
	x , y = a.coerce(self)
	return x == y
end
end

def coerce(other)
	if other.kind_of?(Numeric)
		return RationalPoly(other), self
	elsif other.kind_of?(Polynomial)
		return RationalPoly(other), self
	else
		raise TypeError
	end
end

def to_poly
	q,r=@numerator.divmod(@denominator)
	return q
end
  

def to_s(format="text")
    case format
    when "text"; s1="("; s2=")/("; s3=")"
    when "tex"; s1="\frac{"; s2="}{"; s3="}"
    when "texm"; s1="$\frac{"; s2="}{"; s3="}$"
    when "prog"; s1='RationalPoly("'; s2='","'; s3='")'
    end
	str=s1+@numerator.to_s(format)+s2+@denominator.to_s(format)+s3
	return str
end

def coeff_truncate
	num.coeff_truncate; den.coeff_truncate
end

def coeff_to_Z
	den=@denominator.clone; num=@numerator.clone
	l=Number.lcm(num.lcm_coeff_denom,den.lcm_coeff_denom)
	num=num*l; den=den*l
	g=Number.gcd(num.gcd_coeff_num,den.gcd_coeff_num)
	num=num/g; den=den/g
	num=num.coeff_truncate; den=den.coeff_truncate
	return RationalPoly.new(num,den)
end

def substitute(x)
n=@numerator.substitute(x);  d=@denominator.substitute(x)
if n.kind_of?(Polynomial)||d.kind_of?(Polynomial); r=RationalPoly(n,d)
elsif n.kind_of?(Integer)&&d.kind_of?(Integer); r=Rational(n,d)
else; r=n/d
end
return r
end

def approx(deg=false)
# polynomial approximation
# convert from rational polynomial to Taylor's approximation.
# if deg is Integer then use it,
# else numerator.degree + denominator.degree*2
v=self.reduce; num=v.numerator; den=v.denominator
if den == 0; raise ZeroDivisionError, "denometor is 0" ; end;
if num == 0; return RationalPoly(0); end;
den1=1; while den[0]==0; den=den/Epsilon; den1=den1*Epsilon; end
c=[]; # Array of coefficients.
if deg; degTotal=deg; else degTotal=num.degree + den.degree*2; end

while (num.array.size>0)&&(num!=0)&&((c.size-1)<degTotal)
	w=Number.divII(num[0],den[0]);
	num=(num-w*den);num.array.shift;c=c.push(w);
end
return RationalPoly(Poly(c),den1)
end

def to_approx_poly(deg=false)
return self.approx(deg).numeretor
end

def inspect
	sprintf("RationalPoly(%s, %s)", @numerator.inspect, @denominator.inspect)
end

end # RationalPoly



if $0 == __FILE__
# test code
end
