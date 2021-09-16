#include <stdio.h>
#include "myTree.h"

extern FILE *yyin;
int yylex();
extern int nrSyntaxError, nrLexicalError;
int yyrestart(FILE *);
int yyparse();
Node *root;

int main(int argc, char **argv)
{
    if (argc <= 1)
        return 1;
    FILE *f = fopen(argv[1], "r");
    if (!f)
    {
        perror(argv[1]);
        return 1;
    }
    yyrestart(f);
    yyparse();
    if (nrLexicalError == 0 && nrSyntaxError == 0) 
        preOrderTraverse(root, 0);
    // else 
    //     fprintf(stderr, " LexError:%d, SynError:%d\n", nrLexicalError, nrSyntaxError);
    return 0;
}
