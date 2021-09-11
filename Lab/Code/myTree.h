#ifndef _MY_TREE_H_
#define _MY_TREE_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    ENUM_LEX_INT,
    ENUM_LEX_FLOAT,
    ENUM_LEX_ID,
    ENUM_LEX_SEMI,
    ENUM_LEX_COMMA,
    ENUM_LEX_ASSIGNOP,
    ENUM_LEX_RELOP,
    ENUM_LEX_PLUS,
    ENUM_LEX_MINUS,
    ENUM_LEX_STAR,
    ENUM_LEX_DIV,
    ENUM_LEX_AND,
    ENUM_LEX_OR,
    ENUM_LEX_DOT,
    ENUM_LEX_NOT,
    ENUM_LEX_TYPE,
    ENUM_LEX_LP,
    ENUM_LEX_RP,
    ENUM_LEX_LB,
    ENUM_LEX_RB,
    ENUM_LEX_LC,
    ENUM_LEX_RC,
    ENUM_LEX_STRUCT,
    ENUM_LEX_RETURN,
    ENUM_LEX_IF,
    ENUM_LEX_ELSE,
    ENUM_LEX_WHILE,

    ARBITARY_DELIMITER,

    ENUM_SYN_Program,
    ENUM_SYN_ExtDefList,
    ENUM_SYN_ExtDef,
    ENUM_SYN_ExtDecList,

    ENUM_SYN_Specifier,
    ENUM_SYN_StructSpecifier,
    ENUM_SYN_OptTag,
    ENUM_SYN_Tag,

    ENUM_SYN_VarDec,
    ENUM_SYN_FunDec,
    ENUM_SYN_VarList,
    ENUM_SYN_ParamDec,

    ENUM_SYN_CompSt,
    ENUM_SYN_StmtList,
    ENUM_SYN_Stmt,

    ENUM_SYN_DefList,
    ENUM_SYN_Def,
    ENUM_SYN_DecList,
    ENUM_SYN_Dec,

    ENUM_SYN_Exp,
    ENUM_SYN_Args,

    ENUM_SYN_Error
} ENUM_NODE_TYPE;

// 定义多叉树的节点结构体
typedef struct node_t
{
    char *name;               // 节点名
    int nrChildren;           // 子节点个数
    struct node_t **children; // 指向其自身的子节点，children一个数组，该数组中的元素时node_t*指针
    struct node_t *parent;
    int lineno;
    union {
        int intval;
        double floatval;
        char tokenval[32];
    };
    ENUM_NODE_TYPE enumNodeType;
} Node; // 对结构体重命名

Node *createNode(char *name, int lineno, ENUM_NODE_TYPE);
void freeTree(Node *head);
void preOrderTraverse(Node *T, int depth);
void addChildren(int childsum, Node *parent, ...);

#endif
