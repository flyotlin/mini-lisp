# variable definition
LEX=flex
YACC=bison
CC=g++
OBJECT=minilsp

$(OBJECT): lex.yy.o y.tab.o
	$(CC) lex.yy.o y.tab.o -o $(OBJECT)

lex.yy.o: lex.yy.c y.tab.h lsp_util.h
	$(CC) -c lex.yy.c

y.tab.o: y.tab.c lsp_util.h
	$(CC) -c y.tab.c

lex.yy.c: lsp.l
	$(LEX) lsp.l

y.tab.c y.tab.h: lsp.y
	$(YACC) -d lsp.y

clean:
	rm lex.yy.c y.tab.c y.tab.h *.o