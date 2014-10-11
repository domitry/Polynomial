DATE=$(shell date +'%Y-%m-%d')

gz:
	mkdir poly-ruby
	cp README poly-ruby
	cp Makefile poly-ruby
	cp *rb  poly-ruby
	tar czvf poly-ruby.$(DATE).tar.gz poly-ruby
	rm -r poly-ruby
