# module MathExt
# Extension of standard Math module.
# Functions in this module admit 
#  HyperReal, Rational, RationalPoly in addition to Math.
# Also supprot Integer(Polynomial resp.) 
# with converting to Rational(RationalPoly resp.)
#
#######################################
# K.Kodama(kodama@kobe-kosen.ac.jp) 2000-04-24
#
# This module is distributed freely in the sence of 
# GPL(GNU General Public License).
#######################################
#
# FUNCTION
#   sin, cos, tan, atan, atan2, asin, acos,
#       Trigonometric functions
#   exp, log, log10
#       Exponential and logarithmic functions
#   sinh, cosh, tanh, asinh, acosh, atanh
#       Hyperbolic functions
#   sqrt(x)     square root of x
#   hypot(x,y)  sqrt(x*x+y*y)
#   cbrt(x)     cube root of x
#   gamma(x)    Gamma function
#   lgamma(x)   log(gamma(x))
#   beta(x)     Beta function
#   pi(acc=17)
#     PI of appropriate accuracy "acc" decimal digits in Rational.
#     From Ruby sample script "pi.rb".
# CONSTANT
#   OneOnPI = 1/PI
#   PI2 = PI*2
#   PIh = PI/2
#   PIq = PI/4
#   Ln2 = Math.log(2.0)
#   Ln10 = Math.log(10.0)
#   OneOnLn10 = 1.0/Ln10
#   PI_r = pi(100)  PI in Rational wih accuracy 100 digits.
#   PI2_r = PI_r*2
#   PIh_r = PI_r/2
#   PIq_r = PI_r/4
#   OneOnPI_r = 1/PI_r
# CONVERSION
#     Float#to_r  # Convert to Rational.
#     Float#to_ir # Convert to Integer or Rational.
#     Rational#approximate(accMin=AccuracyMin,accMax=AccuracyMax)
#     Rational#to_f  # re-definition
#     Rational#to_f_str(accuracy=17)
#        convert to string of decimal notation
#        like to_f.to_s with adequate accuracy.
#
# See HART for better methods.
## HART et al,
## Computer Approximations, SIAM Series in Applied Mathematics,
## John Wiley and Sons, New York


class Float
require "rational"
require "hyperreal"

def to_ir #return Integer or Rational. If Inf or NaN,return HyperReal.
f=HyperReal.Inf_to_HyperInf(self) # Check if Inf or NaN.
if f==0.0; return 0;end
if f<0.0; s=-1; f=-f; else s=1;end
i=f.to_i; f=f-i.to_f; r=i.to_r
if f==0.0; return i*s;end
p0=2**10; p=1
while f>0.0; f=f*p0; i=f.to_i; f=f-i.to_f; p=p*p0; r=r+(i.to_r/p); end
return r*s
end

def to_r #return Rational. If Inf or NaN, return HyperReal.
f=HyperReal.Inf_to_HyperInf(self) # Check if Inf or NaN.
if f.kind_of?(HyperReal);return f;end
if f==0.0; return Rational(0);end
if f<0.0; s=-1; f=-f; else s=1;end
i=f.to_i; f=f-i.to_f; r=i.to_r;
p0=2**10; p=1
while f>0.0; f=f*p0; i=f.to_i; f=f-i.to_f; p=p*p0; r=r+(i.to_r/p); end
return r*s
end

end # Float


class Rational
require "hyperreal"

FloatDomainMax=2**(2**10)
AccuracyMax=2**(2**10)
AccuracyMin=2**(2**8)

def approximate(accMin=AccuracyMin,accMax=AccuracyMax)
n=@numerator; d=@denominator;
if d<0; d=-d; s=-1;else s=1;end;  if n<0; n=-n; s=-s;end
while ((n>accMax)||(d>accMax))&&(n>accMin)&&(d>accMin); n=n/2; d=d/2; end
if s==-1; n=-n;end
return Rational(n,d)
end

alias to_f_orig to_f

def to_f
# returu self.approximate(-1,FloatDomainMax).to_f_orig
### another implementation:
n=@numerator; d=@denominator;
if d<0; d=-d; s=-1.0; else s=1.0;end;
if n<0; n=-n; s=-s;end
loop{
	if n.kind_of?(Integer)&&(n<=FloatDomainMax); n=n.to_f;end
	if d.kind_of?(Integer)&&(d<=FloatDomainMax); d=d.to_f;end
	if n.kind_of?(Float)&&d.kind_of?(Float); return s*n/d; end
	n=n/2; d=d/2;
}
end


def to_f_str(accuracy=17)
n=@numerator; d=@denominator;
if d<0; d=-d; s=-1; else s=1;end;
if n<0; n=-n; s=-s;end
a = [[n.to_s.size,d.to_s.size].min,accuracy].max; sw=false
p,q=n.divmod(d); str=p.to_s; n=q*10
if p>0;sw=true;end;
if sw; a=a-str.size;end
if n >0; str=str+".";end
while (a>0)&&(n>0);
	p,q=n.divmod(d); str=str+p.to_s; n=q*10;
	if p>0;sw=true;end;  if sw; a=a-1;end
end
if s<0; str="-"+str;end
return str
end

end # Rational



module MathExt

require "number"
require "rational"
require "polynomial"
require "rationalpoly"

# LOCAL CONSTANT:

PI = Math::PI #=3.141592653589793
PI2 = PI*2.0
PIh = PI/2.0
PIq = PI/4.0
OneOnPI = 1.0/PI
Ln2 = Math.log(2.0)
Ln10 = Math.log(10.0)
OneOnLn10 = 1.0/Ln10


def pi(acc=17)
# PI of appropriate accuracy in Rational.  From Ruby sample script "pi.rb".
k, a, b, a1, b1 = 2, 4, 1, 12, 4
num=0; count=0
while count<=acc
  p=k*k; q=2*k+1; k = k+1
  pa=p*a; pb=p*b; a=a1; b=b1; a1=pa+q*a1; b1=pb+q*b1
  d = a / b; d1 = a1 / b1
  while d == d1
    num=num*10+d; count=count+1
    a=10*(a%b); a1=10*(a1%b1); d=a/b; d1=a1/b1
  end
end
return Rational(num, 10**(count-1))
end

module_function :pi

# PI in Rational
PI_r=pi(100)
PI2_r = PI_r*2
PIh_r = PI_r/2
PIq_r = PI_r/4
OneOnPI_r = 1/PI_r


# Use as cos(x) = CosApprox.substitute(x*x)
#        sin(x) = x*SinApprox.substitute(x*x)
p = Poly("1"); s = Poly(1)
for n in 1..10; s = -s*Poly("x")/((n*2-1)*(n*2)); p = p+s; end
CosApprox = p
#
p = Poly("1"); s = Poly(1)
for n in 1..10; s = -s*Poly("x")/((n*2+1)*(n*2)); p = p+s; end
SinApprox = p

def sin(a)
if a.kind_of?(Numeric);
	if a<0; sgn = -1; x = -a; else sgn = 1; x = a; end
	while x>PI2; x = x-PI2; end 
	if x>PI; sgn = -sgn; x = x-PI; end;
	if x>PIh; x = PI-x; end;
	if x<=PIq; z = x*SinApprox.substitute(x*x)
	else y = PIh-x; z = CosApprox.substitute(y*y)
	end
	if sgn<0; return -z; else return z; end
else return a*SinApprox.substitute(a*a)
end
end

def cos(a)
if a.kind_of?(Numeric); return sin(a+PIh)
else return CosApprox(a*a)
end
end

def tan(a)
if a.kind_of?(Numeric);
	if a<0.0; x = -a; sgn = -1; else x = a; sgn = 1; end
	while (x>PI); x = x-PI; end
	if x>PIh; x = PI-x; sgn = -sgn; end
	z = sin(x)/cos(x)
	if sgn<0; return -z; else return z; end
elsif a.kind_of?(Polynomial); x = RationalPoly(a);
	return sin(x)/cos(x)
else
	return sin(a)/cos(a)
end
end

# Use as atan(x) = x*AtanApprox.substisute(x*x)
#p = Poly("1"); s = Poly(1)
#for n in 1..8; s = -s*Poly("x"); p = p+s/(2*n+1); end
p=RationalPoly("0"); s=RationalPoly("x")
10.downto(1){|i| p=(s*(i*i))/(p+(2*i+1))}
AtanApprox = 1/(p+1)
# printf "AtanApprox: %s\n",AtanApprox

def atan_ap(a)
z = a*AtanApprox.substitute(a*a)
1.times{ z = z - (tan(z)-a)*(cos(z)**2)} # Newton method
return z
end

def atan(a) # return (PI/2, PI/2)
if a.kind_of?(Numeric);
	if a.kind_of?(Integer); x1 = Rational(a);else x1 = a; end
	if x1<0; x = -x1; sgn = -1; else x = x1; sgn = 1; end
	if x<=1; z = atan_ap(x); else	z = PIh - atan_ap(1/x); end
	if sgn<0; return -z; else return z; end
else
	return a*AtanApprox.substitute(a*a)
	#return atan_ap(a)
end
end

def atan2(y,x) # return (-PI, PI]
if x.kind_of?(Integer); x1 = Rational(x); else x1 = x; end
if y.kind_of?(Integer); y1 = Rational(y); else y1 = y; end
if x1>0; x2 = x1
	if y1>=0; quadrant = 1; y2 = y1; else quadrant = 4; y2 = -y1; end
elsif x1<0; x2 = -x1
	if y1>=0; quadrant = 2; y2 = y1; else quadrant = 3; y2 = -y1; end
else
	if y1>0; return PIh; elsif y1<0; return -PIh; else return 0.0; end
end
if y2<=x2; t = atan(y2/x2); else t = PIh-atan(x2/y2); end
case quadrant
when 1; return t
when 2; return PI-t
when 3; return -PI+t
when 4; return -t
end
end

def asin(s) # -PI/2 <= asin(s) <= PI/2
c = sqrt((-s+1)*(s+1)); return atan2(c,s)
end

def acos(c) # 0 <= acos(c) <= PI
s = sqrt((-c+1)*(c+1)); return atan2(c,s)
end

# Use as exp(x)=ExpApprox.substitute(x)
p = Poly("1"); s = Poly(1)
for n in 1..16; s = s*Poly("x")/n; p = p+s; end
ExpApprox = p

def exp(a)
if a.kind_of?(Numeric);
	if a.kind_of?(Integer); return Math::EXP**a; end
	if a<0; x = -a; sgn = -1; else x = a; sgn = 1; end
	shift = 0;
	while x>=1; x = x/2; shift = shift+1; end
	x = x/2; shift = shift+1
	z = ExpApprox.substitute(x)
	for i in 1..shift; z = z*z; end
	if sgn<0; return 1/z; else return z; end
else
	return ExpApprox.substitute(a)
end
end

# Use as log(1+x) = LogApprox.substitute(x)
p = Poly("0"); s = Poly("1") 
for n in 1..10; s = -s*Poly("x"); p = p-s/n; end
LogApprox = p
# printf "LogApprox: %s\n",LogApprox

def log(a)
if a.kind_of?(Numeric);
	if a<=0; raise RuntimeError,"error log of arg<=0."; end
	if a.kind_of?(Integer); x = Rational(a); else x = a; end
	x0=x; shift = 0
	while x<0.7; x = x*2; shift = shift-1; end
	while x>1.4; x = x/2; shift = shift+1; end
	z = LogApprox.substitute(x-1)
	# ln(x*2^n) = ln(x)+ln(2^n) = ln(x)+n*ln(2)
	z = z + Ln2 * shift
	2.times{ z = z-(1-x0/exp(z)) } # Newton's method
	return z
elsif a.kind_of?(Polynomial);
	z = LogApprox.substitute(a-1)
	z = RationalPoly(z);
	2.times{ z = z-(1-x/exp(z)) } # Newton's method
	return z
else
	z = LogApprox.substitute(a-1)
	2.times{ z = z-(1-x/exp(z)) } # Newton's method
	return z
end
end


def log10(x)
return log(x)*OneOnLn10
end

# sqrt(1+x) = SqrtApprox.substitute(x)
p = Poly("1"); p1 = Poly("1")
for i in 1..16; p1 = p1*Poly("x")*(3-2*i)/(2*i); p = p+p1; end
SqrtApprox = p

def sqrt(a)
if a.kind_of?(Numeric);
	if a<0; raise RuntimeError,"error sqrt of arg<0."; end
	if a.kind_of?(Integer); x = Rational(a); else x = a; end
	if x==0; return x; end
	shift = 0
	while x*2<1; x = x*4; shift = shift-1; end
	while x>2; x = x/4; shift = shift+1; end
	z = SqrtApprox.substitute(x-1)
	4.times{ z = (z*z+x)/(z*2) } # Newton's method
	#4.times{ z = z-(z*z-x)/(z*2) } # Newton's method
	if shift>=0; return z*(2**shift); else  return z/(2**(-shift)); end
elsif a.kind_of?(Polynomial);
	if a.zero?; return a; end
	z = SqrtApprox.substitute(a-1); z = RationalPoly(z);
	4.times{ z = (z*z+a)/(z*2) } # Newton's method
	return z
else
	z = SqrtApprox.substitute(a-1)
	4.times{ z = (z*z+a)/(z*2) } # Newton's method
	return z
end
end



# cbrt(x) = CbrtApprox.substitute(x-1)
p = Poly("1"); p1 = Poly("1")
for i in 1..16; p1 = p1*Poly("x")*(4-3*i)/(3*i); p = p+p1; end
CbrtApprox = p

def cbrt(a)
if a.kind_of?(Numeric);
	if a==0; return a; end
	if a.kind_of?(Integer); x = Rational(a); else x = a; end
	if x<0; sgn=-1; x=-x; else sgn=1;end
	shift = 0
	while x*3<1; x = x*8; shift = shift-1; end
	while x>3; x = x/8; shift = shift+1; end
	z = CbrtApprox.substitute(x-1)
	# 4.times{ z = z-(z*z*z-a)/(z*z*3) } # Newton's method
	4.times{ z = (2*z*z*z+x)/(z*z*3) } # Newton's method
	if shift>=0; return z*(2**shift); else  return z/(2**(-shift)); end
	return z*sgn
elsif a.kind_of?(Polynomial);
	if a.zero?; return a; end
	z = SqrtApprox.substitute(a-1); z = RationalPoly(z);
	4.times{ z = (2*z*z*z+a)/(z*z*3) } # Newton's method
	return z
else
	z=Cbrt.substitute(a-1)
	4.times{ z = (2*z*z*z+a)/(z*z*3) } # Newton's method
	return z
end
end

########

def sinh(x)
z = exp(x);
if z.kind_of?(Polynomial); z = RationalPoly(z); end
return (z+1)*(z-1)/(z*2)
end

def cosh(x)
z = exp(x);
if z.kind_of?(Polynomial); z = RationalPoly(z); end
return (z*z+1)/(z*2)
end

def tanh(x)
z = exp(x);
if z.kind_of?(Polynomial); z = RationalPoly(z); end
return (z+1)*(z-1)/(z*z+1)
end

def atanh(t) # -1 < t < 1
return log((t+1)/(-t+1))/2
end

def asinh(s)
c = sqrt(s*2+1); if s>=0; return log(s+c); else return -log(c-s); end
end

def acosh(c) # 0 <= acosh(c)
s = sqrt(c*2-1); return log(s+c)
end

# Gamma(x)
a=[Rational(1,12), Rational(1,30), Rational(53,210), Rational(195,371),
	Rational(2299,22737), Rational(29944523,19733142), 
	Rational(109535241009,48264275462)]
p=RationalPoly(0); s=Poly("x")
6.downto(0){|i| p= a[i]/(p+s)} 
GammaApprox=p

def gamma(a)
if a.kind_of?(Integer);
	if a<=0;return Number.NaN_IEEE754; else return Number.factorial(a);end
elsif a.kind_of?(Float) or a.kind_of?(Rational);
	if a.kind_of?(Rational); x=a.to_f;
	else x=a;
	end
	l=10;
	f1=1; while x<l; f1=f1*x; x=x+1;end
	f2=1; # while x>(l+1); x=x-1; f2=f2*x;end
	g=sqrt(2*PI/x)*exp(x*(log(x)-1)+GammaApprox.substitute(x))
	return (g*f2)/f1
elsif a.kind_of?(Complex);
	raise "Sorry. Gamma for Complex is not implemented."
else
	x=a
	g=sqrt(2*PI/x)*exp(x*(log(x)-1)+GammaApprox.substitute(x))
	return g
end
end

def lgamma(a)
if a.kind_of?(Numeric);
	if a.kind_of?(Integer); x=a.to_f;
		if a<=0;return Number.NaN_IEEE754; 
		else return log(Number.factorial(a));
		end
	elsif a.kind_of?(Rational); x=a.to_f;
	else x=a;
	end
	l=10;
	f1=0.0; while x<l; f1=f1+log(x); x=x+1;end
	f2=0.0; # while x>(l+1); x=x-1; f2=f2+log(x);end
	g=log(x)*(x-0.5)+0.5*log(PI2)-x+GammaApprox.substitute(x)
	return (g+f2)-f1
else
	x=a
	g=log(x)*(x-0.5)+0.5*log(2*PI)-x+GammaApprox.substitute(x)
	return g
end
end

def beta(z,w)
return exp(lgamma(z)+lgamma(w)-lgamma(z+w))
end


def hypot(x,y)
return sqrt(x*x+y*y)
end

module_function :sin, :cos, :tan, :atan, :atan_ap, :atan2
module_function :exp, :log, :sqrt, :cbrt
module_function :sinh, :cosh, :tanh, :asinh, :acosh, :atanh
module_function :asin, :acos, :log10
module_function :gamma, :lgamma, :beta
module_function :hypot
end # MathHyper

if $0 == __FILE__
x=Math::PI/4
s0=Math.sin(x); s1=MathExt.sin(x)
printf "sin(%s)= %s %s diff:%s\n",x, s0,s1,s0-s1
s0=Math.cos(x); s1=MathExt.cos(x)
printf "cos(%s)= %s %s diff:%s\n",x, s0,s1,s0-s1
s0=Math.tan(x); s1=MathExt.tan(x)
printf "tan(%s)= %s %s diff:%s\n",x, s0,s1,s0-s1
s0=Math.atan(x); s1=MathExt.atan(x)
printf "atan(%s)= %s %s diff:%s\n",x, s0,s1,s0-s1
s0=Math.log(x); s1=MathExt.log(x)
printf "log(%s)= %s %s diff:%s\n",x, s0,s1,s0-s1
s0=Math.exp(x); s1=MathExt.exp(x)
printf "exp(%s)= %s %s diff:%s\n",x, s0,s1,s0-s1
s0=Math.sqrt(x); s1=MathExt.sqrt(x)
printf "sqrt(%s)= %s %s diff:%s\n",x, s0,s1,s0-s1
#
x=2.0
s0=Math.sqrt(x); s1=MathExt.sqrt(x);
printf "sqrt(%s)= %s %s %s\n",x, s0,s1,s0-s1
t0=s0*s0; t1=s1*s1
printf "(sqrt(%s))^2= %s %s , diff:%s %s\n",x, t0,t1, x-t0, x-t1
#
x=1.0
s0=Math.atan(x); s1=MathExt.atan(x)
printf "atan(%s)= %s %s diff:%s\n",x, s0,s1,s0-s1
t0=Math.tan(s0); t1=MathExt.tan(s1)
printf "tan(atan(%s))= %s %s , diff:%s %s\n",x, t0,t1, x-t0, x-t1
#
x=1.4
s0=Math.log(x); s1=MathExt.log(x)
printf "log(%s)= %s %s diff:%s\n",x, s0,s1,s0-s1
t0=Math.exp(s0); t1=MathExt.exp(s1)
printf "exp(log(%s))= %s %s , diff:%s %s\n",x, t0,t1, x-t0, x-t1
#
printf "%1.20f\n",Math::PI
printf "%1.20f\n",MathExt::PI
#
x=2; printf "gamma(%s)=%s\n", x, MathExt.gamma(x)
x=3; printf "gamma(%s)=%s\n", x, MathExt.gamma(x)
x=4; printf "gamma(%s)=%s\n", x, MathExt.gamma(x)
x=0.5; printf "gamma(%s)=%s\n", x, MathExt.gamma(x)
       printf " sqrt(PI) =%s\n", MathExt.sqrt(Math::PI)
end
