%{
#include "lsp_util.h"
#include "y.tab.h"

extern "C" {
    int yywrap(void);
    int yylex(void);
}
%}

%%

[0-9]* {
    yylval.type = NUM;
    yylval.num_t = atoi(yytext);
    return NUMBER;
}

. { 
    return yytext[0];
}

%%