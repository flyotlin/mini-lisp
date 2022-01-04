#ifndef LSP_UTIL
#define LSP_UTIL

#include <iostream>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <unordered_map>
#include <stack>

using namespace std;

// overwritten YYSTYPE (yylval)
struct Node {
    string type;

    int val;
    string sval;

    struct Node *left;
    struct Node *right;
    struct Node *cond;    // if statement condition
};
typedef struct Node Node;

#define YYSTYPE Node *  // overwrite YYSTYPE to self-defined struct

#endif