%{
#include "lsp_util.h"

extern "C" {
    void yyerror(const char *msg);
    extern int yylex(void);
}

Node* root;
Node* createNode(Node*, Node*, string);
void traverse(Node*);
%}

%token NUMBER
%token BOOLEAN
%token ID
%token '+' '-' '*' '/' '>' '<' '=' '(' ')' MOD_OP AND_OP OR_OP NOT_OP PRINT_NUM PRINT_BOOL IF_STMT DEFINE_VAR FUN_DECL
%type PROGRAM STMT EXP DEF-STMT PRINT-STMT NUM-OP VARIABLE NUM-OP LOGICAL-OP FUN-EXP FUN-CALL IF-EXP VARIABLE FUN-ID FUN_IDs FUN-BODY FUN-NAME PARAMS TEST-EXP THAN-EXP ELSE-EXP
%type PLUS MINUS MULTIPLY DIVIDE MODULUS GREATER SMALLER EQUAL AND-OP OR-OP NOT-OP

%%

PROGRAM: 
    STMTS {
        root = $1;
    }
;

STMTS:
    STMT STMTS {
        $$ = createNode($1, $2, "non_t");
    }
    | STMT {
        $$ = $1;
    }
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
        $$ = createNode($3, NULL, "pn");
    }
    | '(' PRINT_BOOL EXP ')' {
        $$ = createNode($3, NULL, "pb");
    }

EXP:
    BOOLEAN {
        $$ = $1;
    }
    | NUMBER {
        $$ = $1;
    }
    | VARIABLE
    | NUM-OP {
        $$ = $1;
    }
    | LOGICAL-OP {
        $$ = $1;
    }
    | FUN-EXP
    | FUN-CALL
    | IF-EXP {
        $$ = $1;
    }
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
    '(' '+' EXP PLUS-EXPs ')' {
        $$ = createNode($3, $4, "+");
    }
;

PLUS-EXPs:
    EXP PLUS-EXPs {
        $$ = createNode($1, $2, "+");
    }
    | EXP {
        $$ = $1;
    }
;

MINUS:
    '(' '-' EXP EXP ')' {
        $$ = createNode($3, $4, "-");
    }
;

MULTIPLY:
    '(' '*' EXP MUL-EXPs ')' {
        $$ = createNode($3, $4, "*");
    }
;

MUL-EXPs:
    EXP MUL-EXPs {
        $$ = createNode($1, $2, "*");
    }
    | EXP {
        $$ = $1;
    }
;

DIVIDE:
    '(' '/' EXP EXP ')' {
        $$ = createNode($3, $4, "/");
    }
;

MODULUS:
    '(' MOD_OP EXP EXP ')' {
        $$ = createNode($3, $4, "%");
    }
;

GREATER:
    '(' '>' EXP EXP ')' {
        $$ = createNode($3, $4, ">");
    }
;

SMALLER:
    '(' '<' EXP EXP ')' {
        $$ = createNode($3, $4, "<");
    }
;

EQUAL:
    '(' '=' EXP EQUAL-EXPs ')' {
        $$ = createNode($3, $4, "=");
    }
;

EQUAL-EXPs:
    EXP EQUAL-EXPs {
        $$ = createNode($1, $2, "=");
    }
    | EXP {
        $$ = $1;
    }
;

LOGICAL-OP:
    AND-OP { $$ = $1; }
    | OR-OP { $$ = $1; }
    | NOT-OP { $$ = $1; }
;

AND-OP:
    '(' AND_OP EXP AND-EXPs ')' {
        $$ = createNode($3, $4, "&");
    }
;

AND-EXPs:
    EXP AND-EXPs {
        $$ = createNode($1, $2, "&");
    }
    | EXP {
        $$ = $1;
    }
;

OR-OP:
    '(' OR_OP EXP OR-EXPs ')' {
        $$ = createNode($3, $4, "|");
    }
;

OR-EXPs:
    EXP OR-EXPs {
        $$ = createNode($1, $2, "|");
    }
    | EXP {
        $$ = $1;
    }
;

NOT-OP:
    '(' NOT_OP EXP ')' {
        $$ = createNode($3, NULL, "!");
    }
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

Node* createNode(Node* left, Node* right, string type)
{
    Node* cur = new Node();

    cur->type = type;
    cur->left = left;
    cur->right = right;

    return cur;
}

void traverse(Node* cur)
{
    if (!cur) {
        // cout << "cur type: null" << endl;
        return;
    }

    // cout << "cur type: " << cur->type << ", and cur value: " << cur->ival << endl;
    traverse(cur->left);
    traverse(cur->right);

    if (cur->type == "pn") {
        printf("%d\n", cur->left->ival);
    } else if (cur->type == "pb") {
        if (cur->left->bval == true)  printf("#t\n");
        else    printf("#f\n");
    } else if (cur->type == "+") {
        cur->ival = cur->left->ival + cur->right->ival;
    } else if (cur->type == "-") {
        cur->ival = cur->left->ival - cur->right->ival;
    } else if (cur->type == "*") {
        cur->ival = cur->left->ival * cur->right->ival;
    } else if (cur->type == "/") {
        cur->ival = cur->left->ival / cur->right->ival;
    } else if (cur->type == "%") {
        cur->ival = cur->left->ival % cur->right->ival;
    } else if (cur->type == "&") {
        cur->bval = cur->left->bval && cur->right->bval;
    } else if (cur->type == "|") {
        cur->bval = cur->left->bval || cur->right->bval;
    } else if (cur->type == "!") {
        cur->bval = !cur->left->bval;
    } else if (cur->type == ">") {
        if (cur->left->ival > cur->right->ival) {
            cur->bval = true;
        } else {
            cur->bval = false;
        }
    } else if (cur->type == "<") {
        if (cur->left->ival < cur->right->ival) {
            cur->bval = true;
        } else {
            cur->bval = false;
        }
    } else if (cur->type == "=") {
        cout << cur->left->ival << " " << cur->right->ival << endl;
        if (cur->left->ival == cur->right->ival) {
            cur->bval = true;
        } else {
            cur->bval = false;
        }
    }

}

void yyerror(const char *msg)
{
    cout << msg << "\n";
}

int main(int argc, char *argv[])
{
    yyparse();

    traverse(root);
    return 0;
}