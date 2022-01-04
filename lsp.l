%{
#include "lsp_util.h"
#include "y.tab.h"

extern "C" {
    int yywrap(void);
    int yylex(void);
}
extern int FALSENUM;
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
    yylval = new Node();
    yylval->type = "b";
    if (!strcmp(yytext, "#t"))
        yylval->val = 1;
    else if (!strcmp(yytext, "#f"))
        yylval->val = FALSENUM;
    return BOOLEAN;
}

0|[1-9]{digit}*|"-"[1-9]{digit}* {  /* Positive Number and 0 */
    yylval = new Node();
    yylval->type = "d";
    yylval->val = atoi(yytext);
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

"fun"|"lambda" {
    return FUN_DECL;
}

{letter}({letter}|{digit}|"-")* {   /* IDENTIFIER */
    yylval = new Node();
    yylval->type = "s";
    yylval->sval = yytext;
    return ID;
}

{separator} {   /* Separator, do nothing */    }

. {     /* Tokens not defined in the rules  */
        /* Return the first char, and the   */
        /* token would not meet the grammar */
    return yytext[0];
}

%%