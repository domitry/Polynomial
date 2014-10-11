#!/usr/local/bin/ruby

require "number"

############ tests and samples ###########


def sampleNumber
p=7;n=5; i=Number.inv(n,p);  printf "%d*%d = 1 (mod %d)\n",n,i,p

n=5;  printf "%d! = %d\n",n,Number.factorial(n)

n=[24,81,56];
g,*aj=Number.gcd2(n)
printf "gcd(%s) = %d = %d*(%d)+%d*(%d)+%d(%d)\n",n.join(","),g,n[0],aj[0],n[1],aj[1],n[2],aj[2]
printf "lcm(%s) = %d\n",n.join(","),Number.lcm(n)

n=10000000019; printf "prime?(%d)=%s\n",n,Number::prime?(n)
n=10000000017; printf "prime?(%d)=%s\n",n,Number::prime?(n)
printf "%d = %s\n",n,Number.factor2s(Number.factorize(n),"*")

print "---notation base---\n"
n=14;

b=2;
c=Number.i_to_notation_array(n,b)
str=Number.i_to_notation_str(n,b)
printf "%d=%s(%d)=%s(%d)\n",n, c.reverse,b, str,b

b=3;
c=Number.i_to_notation_array(n,b)
str=Number.i_to_notation_str(n,b)
printf "%d=%s(%d)=%s(%d)\n",n, c.reverse,b, str,b

c=Number.i_to_notation_factorial(n); c.shift
printf "%d=%s(factorial)\n",n, c.reverse.join(",")

str="1010"
b=2; a=Number.notation_str_to_i(str,b)
printf "%s(%d)=%d\n",str,b,a
b=3; a=Number.notation_str_to_i(str,b)
printf "%s(%d)=%d\n",str,b,a


print "----print 10 primes > 10**10 ----\n"
p=10**10; 10.times{ printf "%d \n",p=Number.nextPrime(p) }
end


sampleNumber

# end of this script
