#!/usr/local/bin/ruby

require "rationalpolym"
# require "complex" # Complex coefficients


def sampleRationalPolyM
r1=RationalPolyM("x^2+1","y+2")
r2=RationalPolyM("y+2","x+1")

printf "%s+%s = %s\n",r1,r2,r1+r2
printf "%s-%s = %s\n",r1,r2,r1-r2
printf "%s*%s = %s\n",r1,r2,r1*r2
printf "%s/%s = %s\n",r1,r2,r1/r2
printf "(%s)**2=%s\n",r2,r2**(2)
q,r=r1.divmod(r2)
printf "(%s).divmod(%s)=%s...%s\n",r1,r2,q,r
printf "(%s)derivative by x= %s\n",r1,r1.derivative("x")
printf "(%s)derivative by x,y= %s\n",r1,r1.derivative(["x","y"])
printf "(%s)derivative by x,x,x= %s\n",r1,r1.derivative(["x","x","x"])
end


sampleRationalPolyM
# end of this script
