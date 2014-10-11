#!/usr/local/bin/ruby

require "polynomialm" # multi variable polynomial class
# require "rational" # Rational coefficients
# require "mathn" # new mathematical classes
# require "complex" # Complex coefficients
require "gbasem" # Rational, Complex or Z/pZ coefficients Grobner basis
require "gbasei" # Z coefficient Grobner basis
#

############## sample ############

def samplePolynomialM
	print "-- string to polynomial\n"
	s1="3x^2/2+5.to_r/2*x+7/2"
	f1=PolynomialM(s1)
	printf "%s ==> %s\n",s1,f1
	s1="3x^2/2+5/2*x+7/2"
	f1=PolynomialM(s1)
	printf "%s ==> %s\n",s1,f1

	f1=PolynomialM("x^2+3x*y+y^3")
	f2=PolynomialM("(y-1)^3")
	f3=PolynomialM("x+y^2")
	printf "f1=%s, f2=%s,f3=%s\n",f1,f2,f3

	f4=f1+f2-2*f3*f1+f3**2
	printf "f1+f2-f3*f1+f3**2 = %s\n",f4

	print "-- divmod supprots multi division.\n"
	print "-- It returns a pair [quotients,residue].\n"
	print "-- In the following sample, We get multi division f4 by f2,f3.\n"
	q,r=f4.divmod([f1,f2])
	printf "f4= f1*(%s) + f2*(%s) + (%s)\n", q[0],q[1],r

	print "-- substitute\n"
	f5=f3.substitute("x"=>2,"y"=> 1)
	printf "substitute: %s(2,1) = %s\n",f3,f5

	print "-- We can use substitute method to polynomials.\n"
	print "-- In the following sample, We exchange x and y each other.\n"
	f5=f3.substitute("x"=>PolynomialM("y"),"y"=>PolynomialM("x"))
	printf "substitute: %s(y,x) = %s\n",f3,f5

	print "-- derivative\n"
	f6=f2.derivative(["x","x","y"])
	printf 'f2.derivative(["x","x","y"])=%s'+"\n",f6

	print "-- integral\n"
	f7=f3.integral(["x","y"])
	printf 'f3.integral(["x","y"])=%s'+"\n",f7
end


def sampleGBase
	print "---- sample 1 ---\n"
	print "-- solve equation using Grobner basis\n"
	f1=PolynomialM("x+y+2z-2")
	f2=PolynomialM("2x+3y+6z-5")
	f3=PolynomialM("3x+2y+4z-5")
	printf "%s =0, %s =0, %s =0\n",f1,f2,f3
	gbasis=GBase.getGBase([f1,f2,f3])
	printf "Groebner baseis: %s\n", gbasis.join(", ")
	str="";d=""; gbasis.each{|f| str=str+d+f.to_s+" =0"; d=", "}
	printf "Solution: %s\n", str

	print "---- sample 2 ---\n"
	print "-- Grobner basis in degrevlex order \n"
	f1=PolynomialM("3x^2y-y*z")
	f2=PolynomialM("x*y^2+z^4")
	printf "%s, %s\n",f1,f2
	gbasis=GBase.getGBase([f1,f2])
	printf "Groebner base: %s\n", gbasis.join(", ")

	print "-- with deglex term order\n"
	# Monomial.setTermOrder(t)
	#        t= "lex"(default), "deglex",  "degrevlex"
	Monomial.setTermOrder("deglex")
	gbasis=GBase.getGBase([f1,f2])
	printf "Groebner basis: %s\n", gbasis.join(", ")
	Monomial.setTermOrder

	print "---- sample 3 ---\n"
	print "-- Grobnae basis in Z/5Z coefficients. \n"
	f1=PolynomialM("x^2+y^2+1")
	f2=PolynomialM("x^2y+2x*y+x")
	printf "%s, %s\n",f1,f2
	gbasis=GBase.getGBaseZp([f1,f2],5)
	printf "Groebner basis: %s\n", gbasis.join(", ")
	
	print "--- sample 4 ---\n"
	print "-- Grobner basis in Z coefficnents. \n"
	Monomial.setVarOrder
	Monomial.setTermOrder("lex")
	f1=PolynomialM("6x^2+y^2")
	f2=PolynomialM("10x^2y+2x*y")
	printf "%s, %s\n",f1,f2
	gbasis=GBaseI.getGBaseI([f1,f2])
	printf "Groebner basis: %s\n", gbasis.join(", ")
end

samplePolynomialM
sampleGBase
# end of the script.

