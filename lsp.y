%{
#include "lsp_util.h"

extern "C" {
    void yyerror(const char *msg);
    extern int yylex(void);
}

Node* createNode(Node*, Node*, string);
Node* createNode(Node*, Node*, Node*, string);
void traverse(Node*);

Node* root;
int FALSENUM = -2342377;
unordered_map<string, Node*> global_vars;
stack<unordered_map<string, int>> func_stack;   // function first refers to local var in func_stack, then check global_vars
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
    | VARIABLE {
        // $1->val = global_vars[$1->sval]->val;
        $$ = $1;
        $$->type = "var";
    }
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
    '(' DEFINE_VAR VARIABLE EXP ')' {
        if ($4->type != "func") traverse($4);
        global_vars[$3->sval] = $4;
    }
;

VARIABLE:
    ID
;

FUN-EXP:
    '(' FUN_DECL FUN_IDs FUN-BODY ')' {
        // FUN-EXP直接存要被evaluate的EXP
        $$ = createNode($3, $4, "func");
    }
;

FUN-ID:
    ID FUN-ID {
        $1->left = $2;
        $1->right = NULL;
        $$ = $1;
    }
    | {
        $$ = NULL;
    }
;

FUN_IDs:
    '(' FUN-ID ')' {
        $$ = $2;
    }
;

FUN-BODY:
    EXP {
        $$ = $1;
    }
;

FUN-CALL:
    '(' FUN-EXP PARAMS ')' {
        traverse($3);
        $$ = createNode($3, $2, "func_call");
    }
    | '(' FUN-NAME PARAMS ')' {
        if (global_vars.find($2->sval) != global_vars.end()) {
            $$ = createNode($3, global_vars[$2->sval], "func_call");
        }
    }
;

FUN-NAME:
    ID {
        $$ = $1;
    }
;

PARAMS:
    PARAM-EXP PARAMS {
        $1->left = $2;
        $1->right = NULL;
        $$ = $1;
    }
    | {
        $$ = NULL;
    }
;

PARAM-EXP:
    EXP {
        Node *p = new Node();
        traverse($1);
        p->val = $1->val;
        $$ = p;
    }
;

IF-EXP:
    '(' IF_STMT TEST-EXP THAN-EXP ELSE-EXP ')' {
        $$ = createNode($4, $5, $3, "if");
    }
;

TEST-EXP:
    EXP {
        $$ = $1;
    }
;

THAN-EXP:
    EXP {
        $$ = $1;
    }
;

ELSE-EXP:
    EXP {
        $$ = $1;
    }
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

Node* createNode(Node* left, Node* right, Node* cond, string type)
{
    Node* cur = new Node();

    cur->type = type;
    cur->left = left;
    cur->right = right;
    cur->cond = cond;

    return cur;
}

void traverse(Node* cur)
{
    if (!cur) {
        // cout << "cur type: null" << endl;
        return;
    }
    // if (cur->type == "s") cout << "cur type: " << cur->type << ", and cur value: " << cur->sval << endl;
    // else cout << "cur type: " << cur->type << ", and cur value: " << cur->val << endl;
    traverse(cur->left);
    traverse(cur->right);

    if (cur->type == "pn") {
        printf("%d\n", cur->left->val);
    } else if (cur->type == "pb") {
        if (cur->left->val == FALSENUM)  printf("#f\n");
        else    printf("#t\n");
    } else if (cur->type == "+") {
        cur->val = cur->left->val + cur->right->val;
    } else if (cur->type == "-") {
        cur->val = cur->left->val - cur->right->val;
    } else if (cur->type == "*") {
        cur->val = cur->left->val * cur->right->val;
    } else if (cur->type == "/") {
        cur->val = cur->left->val / cur->right->val;
    } else if (cur->type == "%") {
        cur->val = cur->left->val % cur->right->val;
    } else if (cur->type == "&") {
        if (cur->left->val == FALSENUM || cur->right->val == FALSENUM)
            cur->val = FALSENUM;
        else
            cur->val = 1;
    } else if (cur->type == "|") {
        if (cur->left->val == FALSENUM && cur->right->val == FALSENUM)
            cur->val = FALSENUM;
        else
            cur->val = 1;
    } else if (cur->type == "!") {
        if (cur->left->val == FALSENUM)
            cur->val = 1;
        else
            cur->val = FALSENUM;
    } else if (cur->type == ">") {
        if (cur->left->val > cur->right->val) {
            cur->val = 1;
        } else {
            cur->val = FALSENUM;
        }
    } else if (cur->type == "<") {
        if (cur->left->val < cur->right->val) {
            cur->val = 1;
        } else {
            cur->val = FALSENUM;
        }
    } else if (cur->type == "=") {
        if (cur->left->val == cur->right->val) {
            cur->val = cur->left->val;
        } else {
            cur->val = FALSENUM;
        }
    } else if (cur->type == "if") {
        traverse(cur->cond);
        if (cur->cond->val == FALSENUM) {
            cur->val = cur->right->val;
        } else {
            cur->val = cur->left->val;
        }
    } else if (cur->type == "func_call") {
        Node *x = cur->left;
        Node *y = cur->right->left;

        unordered_map<string, int> locals;
        while (x && y) {
            locals[y->sval] = x->val;
            x = x->left;
            y = y->left;
        }
        
        // cout << "local stack:\n";
        // for (auto i : locals)
        //     cout << i.first << ": " << i.second << "\n";
        // cout << "\n\n";
        func_stack.push(locals);
        traverse(cur->right->right);
        cur->right->val = cur->right->right->val;
        cur->val = cur->right->right->val;
        func_stack.pop();
    } else if (cur->type == "var") {
        // assume only one layer of function call (no recursion)
        if (func_stack.empty()) {
            // cout << "empty\n";
            if (global_vars.find(cur->sval) != global_vars.end())
                cur->val = global_vars[cur->sval]->val;
        } else {
            // cout << "not empty\n";
            auto local_vars = func_stack.top();
            if (local_vars.find(cur->sval) != local_vars.end()) {   // find in local first
                cur->val = local_vars[cur->sval];
            } else {
                if (global_vars.find(cur->sval) != global_vars.end()) {  // find in global
                    cur->val = global_vars[cur->sval]->val;
                }
            }
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