# module GBaseI1
# reduced minimal strong Groebner base for ideal in Z[x]
#     Use as:   glist=GBaseI1.getGBaseI1([f1,f2,f3,...])
#
###############################
# K.Kodama 2000-01-20
#      first version
#
# This module is distributed freely in the sence of 
# GPL(GNU General Public License).
##############################

require "polynomial"
require "pqueue"

module GBaseI1

SQueue=PQueue.new(lambda{|x,y| (x<=>y)==-1}) # "<" retrieves minimal elements first.
GBase=[]

def printGb
print "GBase[\n"
GBase.each{|f| printf "  %s\n",f.to_s}
print "]\n"
end

def absGB
for i in 0..GBase.size-1; if GBase[i].lc<0; GBase[i]=-GBase[i];end; end
end

def makeGBase # make Grobner basis
absGB
GBase.sort!{|f1,f2| f2<=>f1};
while SQueue.size>0
	h=SQueue.pop
	if h.lc<0; h=-h;end
	lcH=h.lc;  i=0;
	while i<GBase.size
		b=GBase[i]
		if (b.degree<=h.degree)&&(b.lc<=lcH)
			q,r=h.divmodI(b); h=r;
			if h.lc<0; h=-h;end;
			lcH=h.lc;  i=0
		else i=i+1
		end
	end
	if ! (h.zero?);
		GBase.each{|b| SQueue.push(b.getSPolyZ(h))}
		GBase.push(h)
		GBase.sort!{|f1,f2| f2<=>f1};
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
GBase.replace(strongGb);  GBase.sort!{|f1,f2| f2<=>f1}
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

def getGBaseI1(fList)
# INITIALIZATION:
GBase.clear
fList.each{|x| 
		if not x.zero? then GBase.push(x.clone); end;
}
if 0==GBase.size then return []; end;
absGB
SQueue.clear
for i in 0..GBase.size-2
	for j in i+1..GBase.size-1
		SQueue.push(GBase[i].getSPolyZ(GBase[j]))
	end
end
makeGBase; makeStrongGB; makeMinimalStrongGB; GBase.sort!{|f1,f2| f2<=>f1};
return GBase
end

module_function :printGb,:absGB
module_function :makeGBase,:makeStrongGB,:makeMinimalStrongGB
module_function :getGBaseI1

end # GBaseI1


def testGBaseI1
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


if $0 == __FILE__
	testGBaseI1
end
# end of script
