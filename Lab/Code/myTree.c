#include "myTree.h"
#include <stdarg.h>

extern int nrSyntaxError;
extern int nrLexicalError;

Node *createNode(char *name, int lineno, ENUM_NODE_TYPE enumNodeType)
{
    Node *q;
    q = (Node *)malloc(sizeof(Node));
    q->name = name;
    q->lineno = lineno;
    q->nrChildren = 0;
    q->children = NULL;
    q->enumNodeType = enumNodeType;
    return q;
}

void freeTree(Node *head)
{
    int i = 0;
    if (head == NULL)
    {
        return;
    }
    for (i = 0; i < head->nrChildren; ++i)
    {
        freeTree(head->children[i]);
    }
    free(head->name);
    free(head);
}

void preOrderTraverse(Node *T, int depth)
{
//     nrSyntaxError = 0;
    if (T == NULL || nrSyntaxError != 0 || nrLexicalError != 0)
        return;
    if (T->nrChildren == 0)
    {
        // lexical
        if (T->enumNodeType < ARBITARY_DELIMITER)
        {
            for (int i = 0; i < depth; i++)
                printf("  ");
            switch (T->enumNodeType)
            {
            case ENUM_LEX_INT:
                printf("%s: %d\n", T->name, T->intval);
                break;
            case ENUM_LEX_FLOAT:
                printf("%s: %f\n", T->name, T->floatval);
                break;
            case ENUM_LEX_ID:
                printf("%s: %s\n", T->name, T->tokenval);
                break;
            case ENUM_LEX_TYPE:
                printf("%s: %s\n", T->name, T->tokenval);
                break;
            default:
                printf("%s\n", T->name);
                break;
            }
        }
        // syntax
        else
        {
            if (T->enumNodeType == ENUM_SYN_Error)
            {
                for (int i = 0; i < depth; i++)
                    printf("  ");
                printf("%s\n", T->name);
            }
            // else        // -> epson
        }
    }
    else
    {
        for (int i = 0; i < depth; i++)
            printf("  ");
        printf("%s (%d)\n", T->name, T->lineno);
    }

    for (int i = 0; i < T->nrChildren; ++i)
    {
        preOrderTraverse(T->children[i], depth + 1);
    }
}

void addChildren(int num, Node *parent, ...)
{
    va_list ap;
    va_start(ap, parent);
    parent->children = (Node **)malloc(sizeof(Node *) * num);
    for (int i = 0; i < num; i++)
    {
        parent->children[i] = va_arg(ap, Node *);
        parent->children[i]->parent = parent;
    }
    parent->lineno = parent->children[0]->lineno;
    parent->nrChildren = num;
    va_end(ap);
}

/* int main()
{
    Node *head = create_node("2");
    Node **C = new Node *[3];
    C[0] = create_node("3");
    C[1] = create_node("4");
    C[2] = create_node("5");
    head->children = C;
    head->nrChildren = 3;
    C = new Node *[4];
    C[0] = head;
    C[1] = create_node("6");
    C[2] = create_node("7");
    C[3] = create_node("8");
    head = create_node("1");
    head->children = C;
    head->nrChildren = 4;
    PreOrderTraverse(head);
} */
