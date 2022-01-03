#ifndef LSP_UTIL
#define LSP_UTIL

#include <iostream>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <vector>

using namespace std;

// mini-lisp type function
struct func_t {
    vector<int> vec;
    string func_name;
};
typedef struct func_t func;

// enum all available mini-lisp types
enum Type {
    BOOL, NUM, FUNC
};
typedef enum Type Type;

// overwritten YYSTYPE (yylval)
struct TypeStruct {
    Type type;
    bool bool_t;
    int num_t;
    func func_t;
};

#define YYSTYPE TypeStruct  // overwrite YYSTYPE to self-defined struct

#endif