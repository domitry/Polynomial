# module GBase
# reduced Groebner base for ideal in K[x,y,z,...]
#   K=Rational, Z/pZ, Complex, Float
#     Use as:   glist=GBase.getGBase([f1,f2,f3,...])
#     Use as:   glist=GBase.getGBaseZp([f1,f2,f3,...],prime)
#
# module GBase
# getGBase(plist)
#     plist be Array of PolynomialM
#     return Array of PolynomialM of Reduced Grobner base 
#     over field Rational, Complex, Float
# getGBaseZp(plist,prime)
#    get Groebner basis on Zp.
#
###############################
# K.Kodama 2000-02-01
#      first version
#
# This module is distributed freely in the sence of 
# GPL(GNU General Public License).
##############################

require "pqueue"

module GBase

SQueue=PQueue.new(lambda{|x,y| x<y}) # retrieves minimal elements first.
# Use priority queue or FILO

GBase=[]

def printGb
print "GBase[\n"
GBase.each{|f| printf "  %s\n",f.to_s}
print "]\n"
end

def getSPoly(f,g)
	lpF=f.lp; ltF=f.lt
	lpG=g.lp; ltG=g.lt
	lcm=lpF.lcm(lpG);
	s=PolynomialM.new([lcm/ltF])*f-PolynomialM.new([lcm/ltG])*g
	return s
end

def getSPolyZp(f,g,prime)
	lpF=f.lp; lcFinv=Number.inv(f.lc,prime)
	lpG=g.lp; lcGinv=Number.inv(g.lc,prime)
	lcm=lpF.lcm(lpG);
	s=PolynomialM.new([lcm/lpF])*f*lcFinv-PolynomialM.new([lcm/lpG])*g*lcGinv
	return s
end

def makeGBase
# make Grobner basis
#print "makeGBase\n"; printGb;
GBase.sort!{|f1,f2| f2<=>f1};
while SQueue.size>0
	s=SQueue.pop
	q,h=s.divmod(GBase)
	if ! (h.zero?);
		GBase.each{|b| SQueue.push(getSPoly(b,h))}
		GBase.push(h)
		GBase.sort!{|f1,f2| f2<=>f1};
	end
end
end

def makeGBaseZp(prime)
# make Grobner basis
GBase.sort!{|f1,f2| f2<=>f1};
while SQueue.size>0
	s=SQueue.pop
	q,h=s.divmodZp(GBase,prime)
	if ! (h.zero?);
		GBase.each{|b| SQueue.push(getSPolyZp(b,h,prime))}
		GBase.push(h)
		GBase.sort!{|f1,f2| f2<=>f1};
	end
end
end

def makeMinimalGBase
GBase.sort!{|f1,f2| f2<=>f1};
i=0
while i<GBase.size
	j=i+1; change=false
	while j<GBase.size
		if GBase[i].lt.divisible?(GBase[j].lt); change=true;break; end
		j=j+1
	end
	if change; GBase[i]=nil;end
	i=i+1
end
GBase.compact!
end

def makeMinimalLcGBase  # make lc = 1
for i in 0..GBase.size-1
	q,r=GBase[i].divmod(GBase[i].lc)
	GBase[i]=q[0]
end
end

def makeMinimalLcGBaseZp(prime) # make lc = 1
for i in 0..GBase.size-1
	cr=Number.inv(GBase[i].lc,prime)
	GBase[i]=(GBase[i]*cr).coeff_to_Zp(prime)
end
end

def makeReducedGBase # Reduced Grobner basis is canonical.
if GBase.size>1;
	GBase.sort!{|f1,f2| f2<=>f1};
	for i in 0..GBase.size-1
		p=GBase[i]; g=GBase.dup; g.delete_at(i)
		q,r=p.divmod(g)
		GBase[i]=r
	end
end
end

def makeReducedGBaseZp(prime)
GBase.sort!{|f1,f2| f2<=>f1};
if GBase.size>1;
	for i in 0..GBase.size-1
		p=GBase[i]; g=GBase.dup; g.delete_at(i)
		q,r=p.divmodZp(g,prime)
		GBase[i]=r
	end
end
end

def getGBase(fList)
# INITIALIZATION:
GBase.clear
fList.each{|x| 
		if not x.zero? then GBase.push(x.clone); end;
}
if 0==GBase.size then return []; end;

SQueue.clear
for i in 0..GBase.size-2
	for j in i+1..GBase.size-1
		SQueue.push(getSPoly(GBase[i],GBase[j]))
	end
end
makeGBase; makeMinimalGBase; makeMinimalLcGBase; makeReducedGBase
# printGb
GBase.sort!{|f1,f2| f2<=>f1}; 
return GBase
end

def getGBaseZp(fList,prime)
# INITIALIZATION:
GBase.clear; SQueue.clear
fList.each{|f| x=f.coeff_to_Zp(prime);
		if not x.zero? then GBase.push(x); end;
 }
if 0==GBase.size then return []; end;

for i in 0..GBase.size-2
	for j in i+1..GBase.size-1
		SQueue.push(getSPolyZp(GBase[i],GBase[j],prime))
	end
end
makeGBaseZp(prime); makeMinimalGBase;
makeMinimalLcGBaseZp(prime); makeReducedGBaseZp(prime)
#printGb
GBase.sort!{|f1,f2| f2<=>f1};
return GBase
end

module_function :printGb, :getSPoly, :getSPolyZp
module_function :makeMinimalGBase
module_function :makeGBase,:makeMinimalLcGBase,:makeReducedGBase
module_function :makeGBaseZp,:makeMinimalLcGBaseZp,:makeReducedGBaseZp
module_function :getGBase,:getGBaseZp
end
