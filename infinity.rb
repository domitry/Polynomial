# InfinityClass
#
#######################################
# K.Kodama(kodama@kobe-kosen.ac.jp) 2000-04-19
#
# This module is distributed freely in the sence of 
# GPL(GNU General Public License).
#######################################
# FUNCTION
#   checkInifnity(x)
#     if x is Inf(-Inf, NaN resp) 
#     then return Infinity(-Infinity, Indefinite resp.)
#     else return x.
# CONSTANT
#   Infinity
#       +infinity
#   InfinityU 
#       complex or unsigned infinity
#   Indefinite
#       indefinite
#   Inf_IEEE754
#       Infinity in the sence of IEEE754 (1.0/0.0)
#       or Object.new
#   NaN_IEEE754
#       NaN in the sence of IEEE754 (0.0/0.0)
#       or Object.new


# print "Check infinity.rb.  1.0/0.0 and 0.0/0.0 may cause error.\n" 


class InfinityClass

def initialize(type,v=0); @type=type; @val=v;end

attr :type
Infn=InfinityClass.new(0) # -Infinty
Fin=InfinityClass.new(1,-1) # negative Finite 
Z =InfinityClass.new(2,0) # Zero
Fi=InfinityClass.new(3,1) # positive Finite
Inf=InfinityClass.new(4) # +Infinity
Fic=InfinityClass.new(5,1) # complex Finite
Infu=InfinityClass.new(6) # complex or unsigned Infinity
Indef=InfinityClass.new(7) # Indefinite


def InfinityClass.cnvInfinityClass(x)
v=checkInfinity(x)
if v.kind_of?(InfinityClass);return v
elsif defined?(Complex)&& x.kind_of?(Complex);
	if x.imag==0; return InfinityClass(2+(x.real<=>0),x.real);
	else return InfinityClass(5,x);
	end
elsif x.kind_of?(Float)||
		x.kind_of?(Integer)||
		(defined?(Rational)&& x.kind_of?(Rational));
	return InfinityClass(2+(x<=>0),x);
else return Indefinite;
end
end



def eql?(o)
if o.kind_of?(InfinityClass); return @type==o.type
else return false
end
end

def hash
@type+@val
end


STbl=["negativeInfinity","negativeFinite","Zero",
	"positiveFinite","posotiveInfinity",
	"complexFinite","unsignedInfinity","Indefinite"];

def to_s
return STbl[@type]
end


NegTbl=[Inf,Fi,Z,Fin,Infn,Fic,Infu,Indef]

def -@
return NegTbl[@type]
end


def readTbl2(o,tbl)
i=@type;
if o.kind_of?(InfinityClass); j=o.type;
elsif defined?(Complex)&& o.kind_of?(Complex);
	if o.image==0; return self.readTbl2(o.real,tbl); 
	else j=5;
	end
elsif o.kind_of?(Float);
	o=checkInfiniteClass(o)
	if o.kind_of?(InfiniteClass); j=o.type
	else j=(o<=>0)+2;
	end
elsif o.kind_of?(Integer)||(defined?(Rational)&&o.kind_of?(Rational));
	j=(o<=>0)+2;
else return Indef
end
return tbl[i][j]
end

##### table  format ######
# self :  other
#      :  Infn -  0  +  Inf c Infu Indef 
# Infn :
# Fin  :
# Z    :
# Fi   :
# Inf  :
# Fic  :
# Infu :
# Indef:

T=Object.new; # need more test
f=Object.new # NaN_IEEE754;

CmpTbl=[ 
[ f,-1,-1,-1,-1, f, f, f],
[ 1, f,-1,-1,-1, f, f, f],
[ 1, 1, 0,-1,-1, f, f, f],
[ 1, 1, 1, f,-1, f, f, f],
[ 1, 1, 1, 1, f, f, f, f],
[ f, f, f, f, f, f, f, f],
[ f, f, f, f, f, f, f, f],
[ f, f, f, f, f, f, f, f]]


def <=>(o) 
return self.readTbl2(o,CmpTbl);
end

def ==(o) 
r=(self<=>o)
if r.kind_of?(Integer); return r==0; else return Number.NaN_IEEE754; end
end

def <=(o) 
r=(self<=>o)
if r.kind_of?(Integer); return r<=0; else return Number.NaN_IEEE754; end
end

def <(o)
r=(self<=>o)
if r.kind_of?(Integer); return r<0; else return Number.NaN_IEEE754; end
end

def >=(o)
r=(self<=>o)
if r.kind_of?(Integer); return r>=0; else return Number.NaN_IEEE754; end
end

def >(o)
r=(self<=>o)
if r.kind_of?(Integer); return r>0; else return Number.NaN_IEEE754; end
end

def between?(a,b)
return (self>a)&&(self<b)
end


AddTbl=[ 
[ Infn, Infn, Infn, Infn,Indef, Infu,Indef,Indef], 
[ Infn,  Fin,  Fin,    T,  Inf,  Fic, Infu,Indef],
[ Infn,  Fin,    Z,   Fi,  Inf,  Fic, Infu,Indef],
[ Infn,    T,   Fi,   Fi,  Inf,  Fic, Infu,Indef],
[Indef,  Inf,  Inf,  Inf,  Inf, Infu,Indef,Indef],
[ Infu,  Fic,  Fic,  Fic, Infu,  Fic, Infu,Indef],
[Indef, Infu, Infu, Infu,Indef, Infu,Indef,Indef],
[Indef,Indef,Indef,Indef,Indef,Indef,Indef,Indef]]

def +(o); 
return self.readTbl2(o,AddTbl);
end


SubTbl=[ 
[Indef, Infn, Infn, Infn, Infn, Infu,Indef,Indef],
[  Inf,Indef,  Fin,  Fin, Infn,  Fic, Infu,Indef],
[  Inf,   Fi,    Z,  Fin, Infn,  Fic, Infu,Indef],
[  Inf,   Fi,   Fi,Indef, Infn,  Fic, Infu,Indef],
[  Inf,  Inf,  Inf,  Inf,Indef, Infu,Indef,Indef],
[ Infu,  Fic,  Fic,  Fic, Infu,  Fic, Infu,Indef],
[Indef, Infu, Infu, Infu,Indef, Infu,Indef,Indef],
[Indef,Indef,Indef,Indef,Indef,Indef,Indef,Indef]]

def -(o); return self.readTbl2(o,SubTbl); end


MulTbl=[ 
[  Inf,  Inf,Indef, Infn, Infn, Infu, Infu,Indef],
[  Inf,   Fi,    Z,  Fin, Infn,  Fic,Infu,Indef],
[Indef,    Z,    Z,    Z,Indef,    Z,Indef,Indef],
[ Infn,  Fin,    Z,   Fi,  Inf,  Fic, Infu,Indef],
[ Infn, Infn,Indef,  Inf,  Inf, Infu, Infu,Indef],
[ Infu,  Fic,    Z,  Fic, Infu,  Fic, Infu,Indef],
[ Infu, Infu,Indef, Infu, Infu, Infu, Infu,Indef],
[Indef,Indef,Indef,Indef,Indef,Indef,Indef,Indef]]

def *(o); return self.readTbl2(o,MulTbl); end

DivTbl=[ 
[Indef,  Inf, Infu, Infn,Indef, Infu,Indef,Indef],
[    Z,   Fi, Infu,  Fin,    Z,  Fic,    Z,Indef],
[    Z,    Z,Indef,    Z,    Z,    Z,    Z,Indef],
[    Z,  Fin, Infu,   Fi,    Z,  Fic,    Z,Indef],
[Indef, Infn, Infu,  Inf,Indef, Infu,Indef,Indef],
[    Z,  Fic, Infu,  Fic,    Z,  Fic,    Z,Indef],
[Indef, Infu, Infu, Infu,Indef, Infu,Indef,Indef],
[Indef,Indef,Indef,Indef,Indef,Indef,Indef,Indef]]

def /(o); return self.readTbl2(o,DivTbl); end

PowTbl=[
[    Z,    Z,Indef, Infu, Infu, Infu, Infu,Indef],
[    T,Indef,    1,Indef,    T,Indef,    T,Indef],
[Indef,Indef,   Fi,    Z,    Z,    Z,    Z,Indef],
[    T,   Fi,    1,   Fi,    T,  Fic,    T,Indef],
[    Z,    Z,Indef,  Inf, Infu,Indef,Indef,Indef],
[    T,  Fic,    1,  Fic,    T,  Fic,    T,Indef],
[    Z,    Z,Indef, Infu, Infu,Indef, Infu,Indef],
[Indef,Indef,Indef,Indef,Indef,Indef,Indef,Indef]]

def **(o);
r=self.readTbl2(o,PowTbl);
if r==T;
	if @val==1; return Indef;
	elsif @val==-1; return Indef;
	elsif @val.abs<1; return 0;
	elsif defined?(Complex)&& @val.kind_of?(Complex); # complex self.abs>1
		return Infu
	elsif @val>1;
		case o.type;
		when 0; return 0;
		when 4; return Inf;
		when 6; return Infu;
		end
	else # @val<-1
		return Infu;
	end
else return r
end
end

def coerce(x)
return InfinityClass.cnvInfinityClass(x),self
end


def inspect
	sprintf("InfinityClass(%s)", self.to_s)
end

end

Infinity=InfinityClass::Inf # +infinity
InfinityU=InfinityClass::Infu # complex or unsigned infinity
Indefinite=InfinityClass::Indef # indefinite

def checkInifnity(x)
if x.kind_of(Float)&& x.to_s=="Infinity"; return Infinity;
elsif x.kind_of(Float)&& x.to_s=="-Infinity"; return -Infinity;
elsif x.kind_of(Float)&& x.to_s=="NaN"; return Indefinite;
else return x
end
end



if $0 == __FILE__
# test code
#print Inf_IEEE754==1.0/0.0," x \n"
#print Inf_IEEE754<=>1,"\n"
#print NaN_IEEE754===0.0/0.0,"\n"
#print 0.0/0.0===0.0/0.0,"\n"
#print Inf_IEEE754<=>1,"\n"
#print NaN_IEEE754<=>1,"\n"
#
#print Indefinite<=>Indefinite,"\n"
#print Infinity<Infinity,"\n"
#print 3.between?(-Infinity,Infinity),"\n"
end
