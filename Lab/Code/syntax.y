%{
#include <stdio.h>
#include <assert.h>
#include "lex.yy.c"
#include "myTree.h"

int yyerror(char* msg);
extern char * stateExpectStrTb[];
Node* root;
#define CREATE_SYNTAX_NODE(tokenName,atDollarDotFirstLine) \
createNode(#tokenName,atDollarDotFirstLine,ENUM_SYN_##tokenName)
int nrSyntaxError=0;

%}

%locations

/* declared tokens */
%token INT FLOAT ID SEMI COMMA ASSIGNOP RELOP PLUS MINUS STAR DIV
%token AND OR DOT NOT TYPE LP RP LB RB LC RC STRUCT RETURN IF ELSE WHILE

%right ASSIGNOP         //8
%left OR                //7
%left AND               //6
%left RELOP             //5
%left PLUS MINUS        //4
%left STAR DIV          //3
%right NOT NEG          //2
%left LP RP LB RB DOT   //1

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

//High-level Definitions

Program:        ExtDefList                  {   $$ = CREATE_SYNTAX_NODE(Program, @$.first_line); 
                                                addChildren(1,$$,$1);
                                                root = $$;
                                            }
                ;

ExtDefList:     ExtDef ExtDefList           {   $$ = CREATE_SYNTAX_NODE(ExtDefList, @$.first_line);
                                                addChildren(2,$$,$1,$2);}
                |                           {   $$ = CREATE_SYNTAX_NODE(ExtDefList, @$.first_line);}
                ;

ExtDef:         Specifier ExtDecList SEMI   {   $$ = CREATE_SYNTAX_NODE(ExtDef, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | Specifier SEMI            {   $$ = CREATE_SYNTAX_NODE(ExtDef, @$.first_line);
                                                addChildren(2,$$,$1,$2);}
                | Specifier FunDec CompSt   {   $$ = CREATE_SYNTAX_NODE(ExtDef, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
//                | Specifier FunDec SEMI     {   $$ = CREATE_SYNTAX_NODE(ExtDef, @$.first_line);
//                                                addChildren(3,$$,$1,$2,$3);}//cnmcnmcnmcnmcnm
//                | Specifier ExtDecList error{   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                | error SEMI                {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                | Specifier error           {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                | Specifier error SEMI      {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                ;
ExtDecList:     VarDec                      {   $$ = CREATE_SYNTAX_NODE(ExtDecList, @$.first_line); 
                                                addChildren(1,$$,$1);}
                | VarDec COMMA ExtDecList   {   $$ = CREATE_SYNTAX_NODE(ExtDecList, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | VarDec error ExtDecList   {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                ;



//Specifiers

Specifier:      TYPE                        {   $$ = CREATE_SYNTAX_NODE(Specifier, @$.first_line); 
                                                addChildren(1,$$,$1);}
                | StructSpecifier           {   $$ = CREATE_SYNTAX_NODE(Specifier, @$.first_line); 
                                                addChildren(1,$$,$1);}
                ;

StructSpecifier:STRUCT OptTag LC DefList RC {   $$ = CREATE_SYNTAX_NODE(StructSpecifier, @$.first_line);
                                                addChildren(5,$$,$1,$2,$3,$4,$5);}
                | STRUCT Tag                {   $$ = CREATE_SYNTAX_NODE(StructSpecifier, @$.first_line);
                                                addChildren(2,$$,$1,$2);}
                ;

OptTag:         ID                          {   $$ = CREATE_SYNTAX_NODE(OptTag, @$.first_line); 
                                                addChildren(1,$$,$1);}
                |                           {   $$ = CREATE_SYNTAX_NODE(OptTag, @$.first_line);}
                ;

Tag:            ID                          {   $$ = CREATE_SYNTAX_NODE(Tag, @$.first_line); 
                                                addChildren(1,$$,$1);}
                ;


//Declarators

VarDec:         ID                          {   $$ = CREATE_SYNTAX_NODE(VarDec, @$.first_line); 
                                                addChildren(1,$$,$1);}
                | VarDec LB INT RB          {   $$ = CREATE_SYNTAX_NODE(VarDec, @$.first_line);
                                                addChildren(4,$$,$1,$2,$3,$4);}
                | VarDec LB error RB        {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
//                | VarDec error            {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                
                ;

FunDec:         ID LP VarList RP            {   $$ = CREATE_SYNTAX_NODE(FunDec, @$.first_line);
                                                addChildren(4,$$,$1,$2,$3,$4);}
                | ID LP RP                  {   $$ = CREATE_SYNTAX_NODE(FunDec, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | ID LP error RP            {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                ;

VarList:        ParamDec COMMA VarList      {   $$ = CREATE_SYNTAX_NODE(VarList, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | ParamDec                  {   $$ = CREATE_SYNTAX_NODE(VarList, @$.first_line);
                                                addChildren(1,$$,$1);}
                ;

ParamDec:       Specifier VarDec            {   $$ = CREATE_SYNTAX_NODE(ParamDec, @$.first_line);
                                                addChildren(2,$$,$1,$2);}
                ;


//Statements

CompSt:         LC DefList StmtList RC      {   $$ = CREATE_SYNTAX_NODE(CompSt, @$.first_line);
                                                addChildren(4,$$,$1,$2,$3,$4);}
                ;

StmtList:       Stmt StmtList               {   $$ = CREATE_SYNTAX_NODE(StmtList, @$.first_line);
                                                addChildren(2,$$,$1,$2);}
                |                           {   $$ = CREATE_SYNTAX_NODE(StmtList, @$.first_line);}
                ;

Stmt:           Exp SEMI                                    {   $$ = CREATE_SYNTAX_NODE(Stmt, @$.first_line);
                                                                addChildren(2,$$,$1,$2);}
                | Exp error SEMI                            {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                | CompSt                                    {   $$ = CREATE_SYNTAX_NODE(Stmt, @$.first_line); 
                                                                addChildren(1,$$,$1);}
                | RETURN Exp SEMI                           {   $$ = CREATE_SYNTAX_NODE(Stmt, @$.first_line);
                                                                addChildren(3,$$,$1,$2,$3);}
                | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE   {   $$ = CREATE_SYNTAX_NODE(Stmt, @$.first_line);
                                                                addChildren(5,$$,$1,$2,$3,$4,$5);}
                | IF LP Exp RP Stmt ELSE Stmt               {   $$ = CREATE_SYNTAX_NODE(Stmt, @$.first_line);
                                                                addChildren(7,$$,$1,$2,$3,$4,$5,$6,$7);}
                | WHILE LP Exp RP Stmt                      {   $$ = CREATE_SYNTAX_NODE(Stmt, @$.first_line);
                                                                addChildren(5,$$,$1,$2,$3,$4,$5);}
                | error SEMI                                {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                | Exp error                                 {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                | RETURN Exp error                          {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                | IF LP error RP Stmt %prec LOWER_THAN_ELSE {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                | IF LP error RP Stmt ELSE Stmt             {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                | WHILE LP error RP Stmt                    {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                ;


//Local Definitions

DefList:        Def DefList                 {   $$ = CREATE_SYNTAX_NODE(DefList, @$.first_line);
                                                addChildren(2,$$,$1,$2);}
                |                           {   $$ = CREATE_SYNTAX_NODE(DefList, @$.first_line);}
                ;

Def:            Specifier DecList SEMI      {   $$ = CREATE_SYNTAX_NODE(Def, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
               | Specifier error SEMI      {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
               | Specifier DecList error   {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                ;

DecList:        Dec                         {   $$ = CREATE_SYNTAX_NODE(DecList, @$.first_line); 
                                                addChildren(1,$$,$1);}
                | Dec COMMA DecList         {   $$ = CREATE_SYNTAX_NODE(DecList, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                ;

Dec:            VarDec                      {   $$ = CREATE_SYNTAX_NODE(Dec, @$.first_line); 
                                                addChildren(1,$$,$1);}
                | VarDec ASSIGNOP Exp       {   $$ = CREATE_SYNTAX_NODE(Dec, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                ;


//Expressions
Exp:            Exp ASSIGNOP Exp            {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | Exp AND Exp               {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | Exp OR Exp                {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | Exp RELOP Exp             {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | Exp PLUS Exp              {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | Exp MINUS Exp             {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | Exp STAR Exp              {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | Exp DIV Exp               {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | LP Exp RP                 {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | MINUS Exp                 {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(2,$$,$1,$2);}
                | NOT Exp                   {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(2,$$,$1,$2);}
                | ID LP Args RP             {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(4,$$,$1,$2,$3,$4);}
                | ID LP RP                  {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | Exp LB Exp RB             {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(4,$$,$1,$2,$3,$4);}
                | Exp DOT ID                {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | ID                        {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line); 
                                                addChildren(1,$$,$1);}
                | INT                       {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line); 
                                                addChildren(1,$$,$1);}
                | FLOAT                     {   $$ = CREATE_SYNTAX_NODE(Exp, @$.first_line); 
                                                addChildren(1,$$,$1);}
                // | Exp ASSIGNOP error        {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                // | Exp AND error             {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}               
                // | Exp OR error              {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}                
                // | Exp RELOP error           {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}             
                // | Exp PLUS error            {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}              
                // | Exp MINUS error           {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}             
                // | Exp STAR error            {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}              
                // | Exp DIV error             {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}               
                // | LP error RP               {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                // | MINUS error               {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                // | NOT error                 {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                // | ID LP error RP            {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                // | Exp LB error RB           {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                | error                     {   $$ = CREATE_SYNTAX_NODE(Error, @$.first_line);/*yyerrok;*/nrSyntaxError++;}
                 
                ;

Args:           Exp COMMA Args              {   $$ = CREATE_SYNTAX_NODE(Args, @$.first_line);
                                                addChildren(3,$$,$1,$2,$3);}
                | Exp                       {   $$ = CREATE_SYNTAX_NODE(Args, @$.first_line); 
                                                addChildren(1,$$,$1);}
                ;

%%
int yyerror(char* msg) {
    fprintf(stderr,"Error type B at Line %d: %s\n",yylineno,msg);
}
