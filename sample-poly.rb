#!/usr/local/bin/ruby -vd

require "polynomial"
# require "rational" # Rational coefficients
# require "mathn" # new mathematical classes
# require "complex" # Complex coefficients
require "gbasei1" # Z-coefficient 1-variable Grobner bases

def  samplePolynomial
	print "-- string to polynomial\n"
	s1="3x^2/2+5/2*x+7/2"
	f1=Polynomial(s1)
	printf "%s ==> %s\n",s1,f1
	s1="3x^2/2+5/2*x+7/2"
	f1=Polynomial(s1)
	printf "%s ==> %s\n",s1,f1

	f1=Polynomial("(x^2-2x+4)^2")
	printf "f1= %s\n",f1
	print "-- integer to polynomial\n"
	f2=Polynomial(2)
	printf "f2= %s\n",f2
	print "-- array to polynomial\n"
	f3=Polynomial([3,2,1])
	printf "f3= %s\n",f3
	f4=Polynomial([6,5,4])
	printf "f4= %s\n",f4
	print "-- term to polynomial\n"
	f5=Polynomial.term(3,2)
	printf "f5= %s\n",f5

	f6=f1+f2*f3+5*f4+f5**2
	printf "f1+f2*f3+5*f4+f5**2=%s\n",f6
	q,r=f1.divmod(f4);
	printf "(%s).divmod(%s)=%s...%s\n",f1,f4,q,r
	print "-- substitule a number.\n"
	f7=f1.substitute(2);  printf "f1(2) = %s\n",f7
	print "-- substitute a polynomial to a polynomial.\n"
	f8=f1.substitute(f3); printf "f1(f3) = %s\n",f8

	print "-- factorization in Integer coefficient\n"
	f=Polynomial("(x^3-1)(x^3+1)")
	printf "%s ==> %s\n",f, Polynomial.factor2s(f.factorize)
	print "-- factorization in Rational coefficient\n"
	f=Polynomial("(x^3-1/27)(x^3+1/8)")
	factors=f.factorize
	printf "%s ==> %s\n",f, Polynomial.factor2s(f.factorize)
	
	print "-- count solutions of f(x)=0\n"
	s="(x^2+1)^2(x-1)" ; f=Poly(s)
	printf "f=%s, #solution= %d\n",s,f.countSolution
	s="(x-1)(x-2)(x-3)" ; f=Poly(s)
	printf "f=%s, #solution= %d\n",s,f.countSolution
	s="(x^2+1)^2(x-1)^2" ; f=Poly(s)
	printf "f=%s, #solution= %d\n",s,f.countSolution
	s="(x-1)^3(x+2)^2" ; f=Poly(s)
	print "We can controle support range and duplications. \n"
	print "By default, range is real number and count duplication.\n"
	printf "f=%s, #solution= %d\n",s,f.countSolution
	printf "f=%s, #(posotive solution)= %d\n",s,f.countSolution(0,Infinity)
	printf "f=%s, #(solution with eliminating duplication)= %d\n",s,f.countSolution(-Infinity,Infinity,false)
	printf "f=%s, #(positive solution with eliminating duplication)= %d\n",s,f.countSolution(0,Infinity,false)

	print "--- Grobner basis in Z[x]---\n"
	f1=Polynomial("2x^(4)-2x^(2)+8x+10")
	f2=Polynomial("3x^(4)+12x+15")
	f3=Polynomial("2x^(5)+12x^(4)-2x^(3)+10x^(2)+58x+62")
	flist=[f1,f2,f3]
	print "basis\n"
	flist.each{|f| printf "%s\n",f}
	flist2=GBaseI1.getGBaseI1(flist)
	print "Groebner basis\n"
	flist2.each{|f| printf "%s\n",f}
end

samplePolynomial
# end of this script
