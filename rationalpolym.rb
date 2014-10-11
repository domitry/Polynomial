# RationalPolyM
#
############################################
# K.Kodama 2000/02/06
#
# Based on rational.rb by Keiju ISHITSUKA(SHL Japan Inc.)
#
# This module is distributed freely in the sence of 
# Ruby's License.
############################################
# --
#   Usage:
#   class RationalPolyM
#
#   RationalPolyM(a, b) or RPolyM(a, b) --> a/b
#       a,b admit Numeric,PolynomialM 
#       and String of polynomial.
#   +, -, *, /, **, %, divmod
#   abs
#       Make leading coefficients of numerator and denominator  positive.
#  derivative(vars)
#  substitute(list)
# CONVERTING:
#   to_poly
#   to_s
#   coeff_to_Z
#       Rational又はInteger係数の場合, 有理数で約分して, 整数係数にする.
#       Bugs.
#          Float, Complex 係数の動作は保証しない.
# TESTING:
#   ==
#   zero?
# NOT IMPLEMENTED
#   <=>
#   reduce

require "polynomialm"
require "rational"

def RationalPolyM(a, b = PolynomialM(1))
	if a.kind_of?(RationalPolyM)
		if b==1; return a;
		elsif b.kind_of?(RationalPolyM)
			if b.zero?; raise ZeroDivisionError, "denometor is 0" ;end
			return a/b
		else
			b=PolynomialM(b)
			if b.zero?; raise ZeroDivisionError, "denometor is 0" ;end
			return a/RationalPolyM.new(b)
		end
	end
	a=PolynomialM(a)
	if b.kind_of?(RationalPolyM)
		if b.zero?; raise ZeroDivisionError, "denometor is 0" ;end
		return RationalPolyM.new(a)/b
	end
	b=PolynomialM(b)
	if b.zero?; raise ZeroDivisionError, "denometor is 0" ;end
    return RationalPolyM.new(a, b)
end

alias RPolyM RationalPolyM


class RationalPolyM


def zero?
	return @numerator.zero?
end

def reduce
	den=@denominator.clone; num=@numerator.clone
	if den.lc < 0; num = -num;  den = -den; end
	#gcd = PolynomialM.gcd(num,den)
	#num,r = num.divmod(gcd);  den,r = den.divmod(gcd)
	l=Number.lcm(num.lcm_coeff_denom,den.lcm_coeff_denom)
	num=num*l; den=den*l
	g=Number.gcd(num.gcd_coeff_num,den.gcd_coeff_num)
	num=num/g; den=den/g
	if den.unit?
		return RationalPolyM.new(num,den)
		# return num/den # As a Polynomial.
	else
		return RationalPolyM.new(num, den)
	end
end


def initialize(num, den=PolynomialM(1))
	den = PolynomialM(den); num = PolynomialM(num)
	# if den.zero?; raise ZeroDivisionError, "denometor is 0" ;end
	if den.lc < 0; num = -num; den = -den;end
	@numerator = num; @denominator = den
end

private :initialize

attr_accessor :numerator
attr_accessor :denominator


def -@
return RationalPolyM(-@numerator, @denominator)
end


def + (a)
	if a.kind_of?(RationalPolyM)
		num = @numerator * a.denominator
		num_a = a.numerator * @denominator
		return RationalPolyM(num + num_a, @denominator * a.denominator)
	elsif a.kind_of?(Numeric)
		return self + RationalPolyM.new(a)
	elsif a.kind_of?(PolynomialM)
		return self + RationalPolyM.new(a)
	else
		x , y = a.coerce(self)
		return x + y
	end
end
  
def - (a)
	return self+(-a)
end

def * (a)
	if a.kind_of?(RationalPolyM)
		num = @numerator * a.numerator
		den = @denominator * a.denominator
		return RationalPolyM.new(num, den)
	elsif a.kind_of?(PolynomialM)
		num = @numerator * a
		den = @denominator
		return RationalPolyM.new(num, den)
	elsif a.kind_of?(Numeric)
		num = @numerator * PolynomialM.new(a)
		den = @denominator
		return RationalPolyM.new(num, den)
	else
		x , y = a.coerce(self)
		return x * y
	end
end
  
def / (a)
	if a.kind_of?(RationalPolyM)
		if a.zero?; raise ZeroDivisionError, "denometor is 0" ;end
		num = @numerator * a.denominator
		den = @denominator * a.numerator
		return RationalPolyM.new(num, den)
	elsif a.kind_of?(Numeric)
		if a==0; raise ZeroDivisionError, "denometor is 0" ;end
		num = @numerator
		den = @denominator * PolynomialM(a)
		return RationalPolyM.new(num, den)
	elsif a.kind_of?(PolynomialM)
		if a.zero?; raise ZeroDivisionError, "denometor is 0" ;end
		num = @numerator
		den = @denominator * a
		return RationalPolyM.new(num, den)
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
			num = PolynomialM(1)
			den = PolynomialM(1)
		end
		return RationalPolyM.new(num, den)
	else
		x , y = other.coerce(self)
		x ** y
	end
end

def divmod(other)
	v = (self / other)
	q,r= v.numerator.divmod([v.denominator])
	return q[0], self-other*q[0]
end

def % (other)
	q,r=self.divmod([other])
	return r
end

def abs
	num=@numerator.clone; if num.lc<0; num=-num;end
	den=@denominator.clone; if den.lc<0; den=-den;end
	return RationalPolyM.new(num,den);
end


def derivative(vars)
num=@numerator; den=@denominator
vars.each{|v|
	if den.maxdeg(v)>0;num=num.derivative([v])*den - num*den.derivative([v])
		den=den*den
	else
		num=num.derivative([v])
	end
}
return RationalPolyM(num,den).reduce
end


def ==(a)
if a.kind_of?(RationalPolyM)
	return (@numerator * a.denominator)==(a.numerator * @denominator)
elsif a.kind_of?(Numeric)
	return @numerator == @denominator*a
elsif a.kind_of?(PolynomialM)
	return @numerator == @denominator*a
else
	x , y = a.coerce(self)
	return x == y
end
end


def coerce(other)
	if other.kind_of?(Numeric)
		return RationalPolyM(other), self
	elsif other.kind_of?(PolynomialM)
		return RationalPolyM(other), self
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
    when "prog"; s1='RationalPolyM("'; s2='","'; s3='")'
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
	return RationalPolyM.new(num,den)
end


def substitute(list)
n=@numerator.substitute(list);  d=@denominator.substitute(list)
if n.kinf_of?(RationalPolyM)||d.kind_of?(RationalPolyM)||
	n.kinf_of?(RationalPoly)||d.kind_of?(RationalPoly);
	r=n/d
elsif n.kinf_of?(PolynomialM)||d.kind_of?(PolynomialM); r=RationalPolyM(n,d)
elsif n.kinf_of?(Polynomial)||d.kind_of?(Polynomial); r=RationalPoly(n,d)
elsif n.kind_of?(Intger)&&d.kind_of?(Integer); r=Rational(n,d)
else; r=n/d
end
return r
end


def inspect
	sprintf("RationalPoly(%s, %s)", @numerator.inspect, @denominator.inspect)
end

end # RationalPoly



if $0 == __FILE__
# test code
end
