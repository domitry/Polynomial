#!/usr/local/bin/ruby

require "rationalpoly"
# require "complex" # Complex coefficients


def sampleRationalPoly
	r1=RationalPoly("x^2+1","x+2")
	r2=RationalPoly("x+2","x+1")

	printf "%s+%s = %s\n",r1,r2,r1+r2
	printf "%s-%s = %s\n",r1,r2,r1-r2
	printf "%s*%s = %s\n",r1,r2,r1*r2
	print "-- We need to write reduction explicitly.\n"
	printf "%s*%s = %s\n",r1,r2,(r1*r2).reduce
	printf "%s/%s = %s\n",r1,r2,r1/r2
	printf "(%s)**2=%s\n",r2,r2**(2)
	q,r=r1.divmod(r2)
	printf "(%s).divmod(%s)=%s...%s\n",r1,r2,q,r
	printf "(%s)'= %s\n",r1,r1.derivative
	printf "(%s)''= %s\n",r1,r1.derivative(2)
	printf "(%s)'''= %s\n",r1,r1.derivative(3)
end


sampleRationalPoly
# end of this script
