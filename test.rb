#!/usr/local/bin/ruby
require "polynomial"
require "elapse"

def timesSep(p1,p2,d1,d2)
	# Assume that d1>=d2
	d00=25
	d=d2.div(2)
	# d1>=d2>=2d
	#printf "d1=%d,d2=%d,d=%d\n",d1,d2,d
	#if d1<d2; raise "test";end
	p1a=Polynomial.new(0,p1.one);p1a.array=p1.array[d+1..d1]
	d1a=d1-d-1
	p1b=Polynomial.new(0,p1.one);p1b.array=p1.array[0..d]; p1b.normalize!
	d1b=p1b.degree
	p2a=Polynomial.new(0,p2.one);p2a.array=p2.array[d+1..d2]
	d2a=d2-d-1
	p2b=Polynomial.new(0,p2.one);p2b.array=p2.array[0..d];p2b.normalize!
	d2b=p2b.degree
	#printf "%s:%s | %s:%s\n", p1a.array.join(","),p1b.array.join(","),p2a.array.join(","),p2b.array.join(",")
	if d2a>=d00; aa=timesSep(p1a,p2a,d1a,d2a); else aa=p1a*p2a; end
	if (d1b>=d2b); if (d2b>=d00); bb=timesSep(p1b,p2b,d1b,d2b); else bb=p1b*p2b; end;
	else if (d1b>=d00); bb=timesSep(p2b,p1b,d2b,d1b); else bb=p1b*p2b; end;
	end
	if d1b>=d1a; p1c=p1b; 0.upto(d1a){|i| p1c.array[i]+=p1a.array[i]}
	else p1c=p1a; 0.upto(d1b){|i| p1c.array[i]+=p1b.array[i]}
	end;
	if d2b>=d2a; p2c=p2b; 0.upto(d2a){|i| p2c.array[i]+=p2a.array[i]}
	else p2c=p2a; 0.upto(d2b){|i| p2c.array[i]+=p2b.array[i]}
	end;
	d1c=p1c.degree; d2c=p2c.degree;
	if (d1c>=d2c); if (d2c>=d00); ab=timesSep(p1c,p2c,d1c,d2c); else ab=p1c*p2c; end;
	else if (d1c>=d00); ab=timesSep(p2c,p1c,d2c,d1c); else ab=p1c*p2c; end
	end
	ab=ab-(aa+bb);
	bb.array=bb.array+Array.new(d+d+2-bb.array.size,p1.zero);
	bb.array=bb.array+aa.array
	0.upto(ab.degree){|i| bb.array[i+d+1]+=ab.array[i]}
	return bb
end;

def timesS(p1,p2)
	d1=p1.degree; d2=p2.degree
	if (d1>=d2); if (d2>=25); p=timesSep(p1,p2,d1,d2); else p=p1*p2; end
	else if (d1>=25); p=timesSep(p2,p1,d2,d1); else p=p1*p2; end
	end;
	return p
end;

n=32*2*2*2
p1=Poly("x+1")**n; p2=Poly("x+2")**n
f1=p1.timesSep(p2,p1.degree,p2.degree)
f2= p1.timesCnv(p2)
# printf "%s\n", f1; printf "%s\n", f2
printf "%d, %s\n" ,n ,  f1==f2

watch=Elapse.new
watch.mark(0)
3.times{p1*p2}
#20.timesSep(p2,p1.degree,p2.degree)}
watch.mark(1)
3.times{p1.timesCnv(p2)}
watch.mark(2)
watch.print(0,1)
watch.print(1,2)
