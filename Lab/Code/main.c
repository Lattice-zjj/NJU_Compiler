#include <stdio.h>
#include "myTree.h"

extern FILE *yyin;
int yylex();
extern int yydebug;
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
    // yydebug=1;
    yyparse();
#ifdef MDEBUG
    fprintf(stderr, " LexError:%d, SynError:%d, T:%d\n", nrLexicalError, nrSyntaxError, root);
#endif
    if (nrLexicalError == 0 && nrSyntaxError ==0) preOrderTraverse(root, 0);
    return 0;
}
