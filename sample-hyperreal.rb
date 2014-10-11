#!/usr/local/bin/ruby

require "hyperreal" # Non-standard real class
require "mathext" # extension for math.

def f1(x)
	return (3*x**2-x-2)/(2*x**2-x-1)
	#  (x-1)(3x+2)/(x-1)(2x+1)
end

def f2(x)
	return (2*x+3)/(4*x+5)
end

def sampleHyperReal

	print "-- Let f1=(3*x**2-x-2)/(2*x**2-x-1).\n"
	
	####### 0/0 (inf)/(inf)
	# x=1 # case of normal Integer.  0/0=ZeroDivisionError¤Ë¤Ê¤ë.
	# printf "f1(%s)=%s\n",x, f1(x)

	# x=1.0 # case of normal Float. 0.0/0.0=NaN.
	# printf "f1(%s)=%s\n",x, f1(x)

	print "-- For limit(x-->1)f(x) in standard number, \n"
	print "-- we need standard part of f(x+epslon) in non-standard analysis.\n"
	x=1+HyperReal::Epsilon
	printf "f1(%s)=%s\n",x, f1(x)

	x=HyperReal::Infinity # infty
	printf "f1(%s)=%s\n",x, f1(x)

	print "-- derivative in the sense of Leibniz \n"
	x=Rational(2); dx=HyperReal::Epsilon
	f=Poly("5x^3+6x^2+7x+8");
	df=(f.substitute(dx+x)-f.substitute(x))
	printf "f'(%s)=%s\n",x, df/dx

	df=(f2(x+dx)-f2(x))
	printf "f2'(%s)=%s\n",x, df/dx

	print "-- We can use as higher order of auto-diff or Tayler series.\n"
	e=HyperReal::Epsilon
	printf "f2(1+e)=%s\n", f2(x+e).to_s(false)
	printf "f2(1+e)=%s\n", f2(x+e).approx(3).to_s(false)
	printf "f2(1+e)=%s\n", f2(e+x).to_approx_poly.to_s("text","e",false)


	print "-- MathExt module gives math functions supporitng HyperReal,Rational...\n"

	# HyperReal::F_to_IR[0]=true # very slow
	HyperReal::F_to_IR[0]=false

	x=1+HyperReal::Epsilon
	v=MathExt.sin(x); 
	printf "sin(%s)=%s %s\n", x, v.to_std.to_f, Math.sin(1.0)

	print "-- We can get derivatives of functions.\n"
	dv=v-MathExt.sin(1)
	printf "(sin)'(1)=%s, cos(1)=%s\n", (dv/HyperReal::Epsilon).to_f,Math.cos(1) 

	print "-- We can get Tayler series.\n"
	printf "sin(%s)=%s\n",x.to_s(false), v.to_approx_poly.to_s("text","x",false)

	print "-- substitute a polynomial (and get a polynomial approximate)\n"
	x=Poly("1+x"); v=MathExt.sin(x)
	printf "sin(%s)=%s\n",x, v

	print "-- substitute a polynomial (and get a polynomial approximate)\n"
	x=RationalPoly(Poly("x"),Poly("x^2+1"))
	v=MathExt.sin(x)
	printf "sin(%s)=%s\n",x,v
end


sampleHyperReal
# end of this script
