mmd:	mmd.l mmd.y
	bison -d mmd.y
	flex --header-file=lex.yy.h mmd.l
	cc -o $@ mmd.tab.c lex.yy.c -ll

.PHONY: clean test

test: test.mmd
	./mmd test.mmd >test.html

t0: test-0.mmd
	./mmd test-0.mmd

t1: test-1.mmd
	./mmd test-1.mmd

clean:
	-rm lex.yy.c
	-rm lex.yy.h
	-rm mmd.tab.c
	-rm mmd.tab.h
	-rm mmd
	-rm test.html

