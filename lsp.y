%{
#include "lsp_util.h"

extern "C" {
    void yyerror(const char *msg);
    extern int yylex(void);
}
%}

%token NUMBER
%token BOOLEAN
%token ID
%token '+' '-' '*' '/' '>' '<' '=' '(' ')' MOD_OP AND_OP OR_OP NOT_OP PRINT_NUM PRINT_BOOL IF_STMT DEFINE_VAR FUN_DECL
%type PROGRAM STMT EXP DEF-STMT PRINT-STMT NUM-OP VARIABLE NUM-OP LOGICAL-OP FUN-EXP FUN-CALL IF-EXP NUM-OP-EXPs VARIABLE FUN-ID FUN_IDs FUN-BODY FUN-NAME PARAMS TEST-EXP THAN-EXP ELSE-EXP
%type PLUS MINUS MULTIPLY DIVIDE MODULUS GREATER SMALLER EQUAL AND-OP OR-OP NOT-OP

%%

PROGRAM: 
    STMT PROGRAM {
        $$ = $1;
    }
    |
;

STMT:
    EXP
    | DEF-STMT
    | PRINT-STMT {
        $$ = $1;
    }
;

PRINT-STMT:
    '(' PRINT_NUM EXP ')' {
        if ($3.type == NUM_T)
            cout << $3.num_t << endl;
        else
            cout << "some error happened\n";
    }
    | '(' PRINT_BOOL EXP ')'

EXP:
    BOOLEAN
    | NUMBER {
        $$ = $1;
    }
    | VARIABLE
    | NUM-OP {
        $$ = $1;
    }
    | LOGICAL-OP
    | FUN-EXP
    | FUN-CALL
    | IF-EXP
;

NUM-OP-EXPs:
    EXP NUM-OP-EXPs {
        $$.type = NUM_T;
        $$.num_t = $1.num_t + $2.num_t;
    }
    |
;

NUM-OP:
    PLUS { $$ = $1; } 
    | MINUS { $$ = $1; }
    | MULTIPLY { $$ = $1; }
    | DIVIDE { $$ = $1; }
    | MODULUS { $$ = $1; }
    | GREATER { $$ = $1; }
    | SMALLER { $$ = $1; }
    | EQUAL { $$ = $1; }
;

PLUS:
    '(' '+' EXP NUM-OP-EXPs ')' {
        $$.type = NUM_T;
        $$.num_t = $3.num_t + $4.num_t;
    }
;

MINUS:
    '(' '-' EXP EXP ')' {
        $$.type = NUM_T;
        $$.num_t = $3.num_t - $4.num_t;
    }
;

MULTIPLY:
    '(' '*' EXP NUM-OP-EXPs ')' {
        $$.type = NUM_T;
        $$.num_t = $3.num_t * $4.num_t;
    }
;

DIVIDE:
    '(' '/' EXP EXP ')' {
        $$.type = NUM_T;
        $$.num_t = $3.num_t / $4.num_t;
    }
;

MODULUS:
    '(' MOD_OP EXP EXP ')' {
        $$.type = NUM_T;
        $$.num_t = $3.num_t % $4.num_t;
    }
;

GREATER:
    '(' '>' EXP EXP ')'
;

SMALLER:
    '(' '<' EXP EXP ')'
;

EQUAL:
    '(' '=' EXP NUM-OP-EXPs ')'
;

LOGICAL-OP:
    AND-OP | OR-OP | NOT-OP
;

AND-OP:
    '(' AND_OP EXP NUM-OP-EXPs ')'
;

OR-OP:
    '(' OR_OP EXP NUM-OP-EXPs ')'
;

NOT-OP:
    '(' NOT_OP EXP ')'
;

DEF-STMT:
    '(' DEFINE_VAR VARIABLE EXP ')'
;

VARIABLE:
    ID
;

FUN-EXP:
    '(' FUN_DECL FUN_IDs FUN-BODY ')' {
        // FUN-EXP直接存要被evaluate的EXP
    }
;

FUN-ID:
    ID FUN-ID
    |
;

FUN_IDs:
    '(' FUN-ID ')'
;

FUN-BODY:
    EXP
;

FUN-CALL:
    '(' FUN-EXP PARAMS ')'
    | '(' FUN-NAME PARAMS ')'
;

FUN-NAME:
    ID
;

PARAMS:
    EXP PARAMS
    |
;

IF-EXP:
    '(' IF_STMT TEST-EXP THAN-EXP ELSE-EXP
;

TEST-EXP:
    EXP
;

THAN-EXP:
    EXP
;

ELSE-EXP:
    EXP
;

%%

void yyerror(const char *msg)
{
    cout << msg << "\n";
}

int main(int argc, char *argv[])
{
    yyparse();
    return 0;
}