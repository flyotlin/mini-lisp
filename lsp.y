%{
#include "lsp_util.h"

extern "C" {
    void yyerror(const char *msg);
    extern int yylex(void);
}
%}

%token<num_t> NUMBER

%%

program: NUMBER {
    cout << "the number * 10 = " << $1 * 10 << endl;
}
;

%%

void yyerror(const char *msg)
{
    cout << msg << "\n";
    // printf("%s\n", msg);
}

int main(int argc, char *argv[])
{
    yyparse();
    return 0;
}