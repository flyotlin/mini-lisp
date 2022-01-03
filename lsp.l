%{
#include "lsp_util.h"
#include "y.tab.h"

extern "C" {
    int yywrap(void);
    int yylex(void);
}
%}

separator "\t"|"\n"|"\r"|" "
letter [a-z]
digit [0-9]

%%

"print-num" {
    return PRINT_NUM;
}

"print-bool" {
    return PRINT_BOOL;
}

"#t"|"#f" {     /* bool-val */
    yylval.type = BOOL_T;
    if (!strcmp(yytext, "#t"))
        yylval.bool_t = true;
    else if (!strcmp(yytext, "#f"))
        yylval.bool_t = false;
    return BOOLEAN;
}

0|[1-9]{digit}*|"-"[1-9]{digit}* {  /* Positive Number and 0 */
    yylval.type = NUM_T;
    yylval.num_t = atoi(yytext);
    return NUMBER;
}

"+"|"-"|"*"|"/"|">"|"<"|"="|"("|")" {
    return yytext[0];
}

"mod" {
    return MOD_OP;
}

"and" {
    return AND_OP;
}

"or" {
    return OR_OP;
}

"not" {
    return NOT_OP;
}

"if" {
    return IF_STMT;
}

"define" {
    return DEFINE_VAR;
}

"fun" {
    return FUN_DECL;
}

{letter}({letter}|{digit}|"-")* {   /* IDENTIFIER */
    yylval.type = ID_T;
    yylval.id_t = yytext;
    return ID;
}

{separator} {   /* Separator, do nothing */    }

. {     /* Tokens not defined in the rules  */
        /* Return the first char, and the   */
        /* token would not meet the grammar */
    return yytext[0];
}

%%