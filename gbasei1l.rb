# module GBaseI1L
# canonical base for ideal in Z<x> in the sence of 
# pseudo reduced minimal strong Groebner base
#     Use as:   glist=GBaseI1L.getGBaseI1L([f1,f2,f3,...])
#
###############################
# K.Kodama 2000-02-17
#      first version
#
# This module is distributed freely in the sence of 
# GPL(GNU General Public License).
##############################

require "polynomial"
require "gbasei1"

module GBaseI1L


SQueue=PQueue.new(lambda{|x,y| x<y}) # retrieves minimal elements first.
GBase=[]
GPoly=Poly(0)

def printGb
print "GBase[\n"
GBase.each{|f| printf "  %s\n",f.to_s}
print "]\n"
end

def absGB
for i in 0..GBase.size-1
	if GBase[i].lc<0; GBase[i]=-GBase[i];end
end
end

def shift0(f)
	h=f.clone; while h[0]==0; h.array.shift; end
	return h.normalize!
end

def sortFuncGb(f,g)
cF=f.lc.abs; cG=g.lc.abs
if (cF != cG); return cF<=>cG
else return f.degree<=>g.degree
end
end

def getSPolyZ2(f,g) # S in Z<x>
	fc=f[0]; gc=g[0]; gcd=Number.gcd(fc.abs,gc.abs); # lcm=fc*gc/gcd
	h=f*(gc.div(gcd))-g*(fc.div(gcd))
	return h/Poly("x")
end

def getSPolyZ3(f,g) # S in Z<x>
	fc=f.lc; gc=g[0]
	gcd=Number.gcd(fc.abs,gc.abs); # lcm=fc*gc/gcd
	
	return getSPolyZ2(f*(gc.div(gcd)),g)
end


def makeGBaseI1L # make Grobner basis
absGB
GBase.sort!{|f1,f2| sortFuncGb(f2,f1)};
while SQueue.size>0
	h=SQueue.pop
	if h.lc<0; h=-h;end
	lcH=h.lc
	i=0;
	while i<GBase.size
		b=GBase[i]
		if (b.degree<=h.degree)&&(b.lc<=lcH)
			q,h=h.divmodI(b);
			if h.lc<0; h=-h;end;
			lcH=h.lc
			i=0
		else i=i+1
		end
	end
	if ! (h.zero?);
		h=shift0(h)
		GBase.each{|b| SQueue.push(h.getSPolyZ(b))}
		SQueue.push(getSPolyZ2(h,GPoly))
		SQueue.push(getSPolyZ3(h,GPoly))
		GBase.push(h)
		GBase.sort!{|f1,f2| sortFungGb(f1,f2)};
	end
end
end


def makeStrongGB  # make strong Grobner basis
absGB; strongGb=[]; i=0
sat=[]  #saturated subset
GBase.sort!{|f1,f2| f1<=>f2}
while i<GBase.size
	deglcm=GBase[i].degree
	while (i+1 <=GBase.size-1)&&(deglcm==GBase[i+1].degree); i=i+1; end
	sat=GBase[0..i] # set saturated subset
	cj=[]; sat.each_index{|k| cj.push(sat[k].lc)}
	cJ,*aj=Number.gcd2(cj); fJ=Polynomial(0)
	sat.each_with_index{|f,k| fJ=fJ+ Polynomial.term(aj[k],deglcm-f.degree)*f}
	strongGb.push(fJ)
	i=i+1
end
GBase.replace(strongGb); GBase.sort!{|f1,f2| f2<=>f1}
end



def makeMinimalStrongGB # reduced minimal strong GB
new=true
while new
	new=false
	GBase.sort!{|f1,f2| f2<=>f1};
	for i in 0..GBase.size-2;
		for j in i+1..GBase.size-1
		q,r=GBase[i].divmodI(GBase[j])
		if ! q.zero?; new=true; GBase[i]=r.clone;end
		end;
	end
	g1=[]
	GBase.each{|f| if ! f.zero?;g1.push(f);end}
	GBase.replace(g1)
end
end


def reverseDeg(f)
h=f.clone.normalize!; h.array.reverse!; return h.normalize!
end

def shift0GBase
sFlg=false
for i in 0..GBase.size-1
	sFlg=sFlg||(GBase[i][0]==0)
	GBase[i]=shift0(GBase[i])
end
return sFlg
end

def getGBaseI1L(fList)
# INITIALIZATION:
GBase.replace(GBaseI1.getGBaseI1(fList))
if 0==GBase.size then return []; end;
while shift0GBase
	GBase.replace(GBaseI1.getGBaseI1(GBase))
end
listr=[]
GBase.each{|f| listr.push(reverseDeg(f))}
gf=Poly(2)
listr.each{|f|
	if (f.lc.abs==1)&&((gf.lc.abs != 1)||(f.degree<g.degree));
		gf=f.clone
	end
}
if gf.lc.abs != 1
	listr=GBaseI1.getGBaseI1(listr); gf=listr[0].clone
end
if gf.lc<0;gf=-gf;end
GPoly.array.replace(reverseDeg(gf).array)
SQueue.clear
for i in 0..GBase.size-1
	SQueue.push(getSPolyZ2(GBase[i],GPoly))
	SQueue.push(getSPolyZ3(GBase[i],GPoly))
end
makeGBaseI1L
makeStrongGB
makeMinimalStrongGB
GBase.sort!{|f1,f2| f2<=>f1};
return GBase
end


module_function :printGb,:absGB
module_function :getSPolyZ2,:getSPolyZ3,:reverseDeg,:sortFuncGb,:shift0,:shift0GBase
module_function :makeGBaseI1L,:makeStrongGB,:makeMinimalStrongGB
module_function :getGBaseI1L

end # GBaseI1L



def testGBaseAlex
print "--- Grobner basis in Z<x>---\n"
f1=Poly("2x^(4)-2x^(2)+8x+10")
f2=Poly("3x^(4)+12x+15")
f3=Poly("2x^(5)+12x^(4)-2x^(3)+10x^(2)+58x+62")
flist=[f1,f2,f3]
print "basis\n"
flist.each{|f| printf "%s\n",f}
flist2=GBaseI1L.getGBaseI1L(flist)
print "Groebner basis in Z<x>\n"
flist2.each{|f| printf "%s\n",f}
end


if $0 == __FILE__
	testGBaseAlex
end
# end of script
