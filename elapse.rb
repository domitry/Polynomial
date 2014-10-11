class Elapse
    Times = if defined? Process.times then Process else Time end
	def initialize
		@markPt=[]
		if defined? yield then time; end
	end;
	def mark(n=-1)
		if 0>n then n=@markPt.size; end
		@markPt[n]=Float(Times.times[0])
		return n
	end
	def to_f(startPt=-2,endPt=-1)
		return @markPt[endPt]-@markPt[startPt]
	end;
	def elapse(startPt=-2,endPt=-1)
		return to_f(startPt,endPt)
	end
	def to_s(startPt=-2,endPt=-1)
		return to_f(startPt,endPt).to_s
	end
	def print(startPt=-2,endPt=-1)
		printf "Elapsed_time: %f\n", to_s(startPt,endPt)
	end;

	def time # for block
		mark; yield; mark;
	end
	def Elapse::time
		t=new; t.mark; yield; t.mark; return t
	end
end;

if $0 == __FILE__ then
	Elapse::time{ 1000.times{x=9**1111} }.print
	Elapse::new{ 1000.times{x=9**1111} }.print
	
	exit
	t=Elapse::new
	
	t.mark # mark point 0
	1000.times{x=9**3333}
	t.mark # mark point 1
	t.print # elapsed time between point 0 to 1
	
	t.mark # mark point 2
	1000.times{x=9**5555}
	t.mark # mark point 3
	t.print # elapsed time between point 2 to 3
	
	t.print(0,3) # elapsed time between point 0 to 3
	
exit
	## Example

	a=9
	b=10000
	ite=100

	Elapse::time{ite.times{x=a**b}}.print

	exit

	t=Elapse::new
	t.mark # mark point 0
	ite.times{x=a**b}
	t.mark # mark point 1
	t.print # elapsed time between point 0 to 1
	t.mark # mark point 2
	ite.times{x=a**b}
	t.mark # mark point 3
	t.print # elapsed time between point 2 to 3
	t.print(0,3) # elapsed time between point 0 to 3


end
