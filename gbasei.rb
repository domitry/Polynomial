# module GBaseI
# reduced minimal strong Groebner base for ideal in Z[x,y,z,...]
#     Grobner basis in Z[x,y,..].
#     Use as:   glist=GBaseI.getGBaseI([f1,f2,f3,...])
###############################
# K.Kodama 2000-02-04
#      first version
#
# This module is distributed freely in the sence of 
# GPL(GNU General Public License).
##############################

require "polynomialm"
require "pqueue"

module GBaseI

SQueue=PQueue.new(lambda{|x,y| x<y}) # retrieves minimal elements first.
GBase=[]

def printGb
print "GBase[\n"
GBase.each{|f| printf "  %s\n",f.to_s}
print "]\n"
end

def getSPolyZ(f,g)
	lpF=f.lp; lcF=f.lc
	lpG=g.lp; lcG=g.lc
	lcmP=lpF.lcm(lpG); lcmC=Number.lcm(lcF.abs,lcG.abs); # lcm=fc*gc/gcd
	s=PolynomialM(lcmP/lpF)*f*(lcmC.div(lcF))-PolynomialM(lcmP/lpG)*g*(lcmC.div(lcG))
	return s
end

def makeGBaseI
# make Grobner basis
GBase.sort!{|f1,f2| f2<=>f1};
if $0 == __FILE__
	print "makeGBaseI\n";
	printGb
end
while SQueue.size>0
	s=SQueue.pop
	q,h=s.divmodI(GBase)
	if ! (h.zero?);
		GBase.each{|b| SQueue.push(getSPolyZ(b,h))}
		GBase.push(h)
		GBase.sort!{|f1,f2| f2<=>f1};
	end
end
if $0 == __FILE__
	print "end: makeGBaseI\n";
	printGb
end
end


StrongGb=[]

def searchSaturatedSubsetI(i,lcmP)
if i>=GBase.size;
	sat=[] # set saturated subset
	# lcmP: lcm of j[*].lp.
	for poly in GBase
		if lcmP.divisible?(poly.lp); sat.push(poly);end
	end
	if sat.empty?; return; end
	cj=[]; sat.each_index{|k| cj.push(sat[k].lc)}
	cJ,*aj=Number.gcd2(cj)
	fJ=PolynomialM(0)
	sat.each_with_index{|f,k| fJ=fJ+ PolynomialM(lcmP/f.lp)*f*aj[k]}
	StrongGb.push(fJ)
	if $0 == __FILE__
		printf "add fJ= %s\n", fJ;
	end
else
	lp=GBase[i].lp
	searchSaturatedSubsetI(i+1,lcmP)
	if !(lcmP.divisible?(lp));
		lcmP=lcmP.lcm(lp); searchSaturatedSubsetI(i+1,lcmP);
	end
end
end


def reductionSameLpI
GBase.sort!{|f1,f2| f2<=>f1}
if $0 == __FILE__
	print "reductionSameLp\n";
	printGb
end
# Make GBase[] have different lp.
i=0
while i<GBase.size-1
	j=i+1
	while j<GBase.size
		if 0==(GBase[i].lp<=>GBase[j].lp);
			gcd,*a=Number.gcd2(GBase[i].lc,GBase[j].lc)
			f=GBase[i]*a[0]+GBase[j]*a[1]
			GBase[i]=f; GBase.delete_at(j)
		else j=j+1
		end
	end
	i=i+1
end
if $0 == __FILE__
	print "end: reductionSameLp\n";
	printGb
end
end


def makeStrongGBI  # make strong Grobner basis
if $0 == __FILE__
	print "makeStrongGBI\n";
	printGb
end
for i in 0..GBase.size-1
	if GBase[i].lc<0; GBase[i]=-GBase[i];end
end
reductionSameLpI
# for all saturated subset 
GBase.sort!{|f1,f2| f2<=>f1}
if $0 == __FILE__
	print "serach Saturated subset\n";
	printGb
end
StrongGb.clear
searchSaturatedSubsetI(0,Monomial(1))
GBase.replace(StrongGb)
if $0 == __FILE__
	print "makeStrongGBI StrongGB\n";
	printGb
end
reductionSameLpI
GBase.sort!{|f1,f2| f2<=>f1}
if $0 == __FILE__
	print "end: makeStrongGBI\n";
	printGb
end
end


def makeMinimalStrongGBI
g=[]
GBase.sort!{|f1,f2| f2<=>f1};
if $0 == __FILE__
	print "makeMinimalStrongGBI\n";
	printGb
end
i=0
while (GBase.size>1)and(i<GBase.size)
	p=GBase[i]; g=GBase.dup; g.delete_at(i)
	q,r=p.divmodI(g)
	if r.zero?; GBase.delete_at(i);
	else GBase[i]=r; i=i+1;
	end
end
GBase.sort!{|f1,f2| f2<=>f1};
if $0 == __FILE__
	print "end: makeMinimalStrongGBI\n";
	printGb
end
end


def getGBaseI(fList)
# INITIALIZATION:
GBase.clear
fList.each{|x| 
		if not x.zero? then GBase.push(x.clone); end;
}
if 0==GBase.size then return []; end;

SQueue.clear
for i in 0..GBase.size-2
	for j in i+1..GBase.size-1
		SQueue.push(getSPolyZ(GBase[i],GBase[j]))
	end
end
makeGBaseI
#printGb
makeStrongGBI
#printGb
makeMinimalStrongGBI
#printGb
GBase.sort!{|f1,f2| f2<=>f1}; return GBase
end


module_function :printGb, :getSPolyZ
module_function :searchSaturatedSubsetI,:reductionSameLpI
module_function :makeGBaseI,:makeStrongGBI,:makeMinimalStrongGBI
module_function :getGBaseI

end # GBaseI



def testGBaseI
print "--- Grobner basis in Z[x,y,... ]---\n"
print "--- sample 1---\n"
f1=PolynomialM("2x+3y+3")
f2=PolynomialM("x+5y+2")
gb=GBaseI.getGBaseI([f1,f2])
print gb.join(", "),"\n"


print "--- sample 2---\n"
f1=PolynomialM("2x+3y+3")
f2=PolynomialM("x+5y+2")
f3=PolynomialM("x*y-1")
gb=GBaseI.getGBaseI([f1,f2,f3])
print gb.join(", "),"\n"


# sample from 
#    William W.Adams, Philippe Loustaunau
#    "An Introduction to Groebner Bases",
#    AMS GSM(Graduale Study in Mathematics) vol.3

print "--- sample 4.5.5 ---\n"
f1=PolynomialM("3x^2*y+7y")
f2=PolynomialM("4x*y^2-5x")
gb=GBaseI.getGBaseI([f1,f2])
print gb.join(", "),"\n"


print "--- sample ex.4.5.5a ---\n"
Monomial.setVarOrder(["y","x"])
Monomial.setTermOrder("lex")
f1=PolynomialM("2x*y-x")
f2=PolynomialM("3y-x^2")
gb=GBaseI.getGBaseI([f1,f2])
print gb.join(", "),"\n"


print "--- sample ex.4.5.5b ---\n"
Monomial.setVarOrder
Monomial.setTermOrder("deglex")
f1=PolynomialM("3x^2y-3y*z+y")
f2=PolynomialM("5x^2z-8z^2")
gb=GBaseI.getGBaseI([f1,f2])
print gb.join(", "),"\n"


print "--- sample ex.4.5.5c ---\n"
Monomial.setVarOrder
Monomial.setTermOrder("lex")
f1=PolynomialM("6x^2+y^2")
f2=PolynomialM("10x^2y+2x*y")
gb=GBaseI.getGBaseI([f1,f2])
print gb.join(", "),"\n"
end # testGBaseI


if $0 == __FILE__
	testGBaseI
end
# end of script
