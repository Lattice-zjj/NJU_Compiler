%top{
    #include <stdint.h>
    #include <inttypes.h>
    #include <string.h>
    #include "myTree.h"
    #define YYSTYPE Node*
    #include "syntax.tab.h"
    #define MDEBUG 
    #define CREATELEXNODE(tokenName) \
        yylval = createNode(#tokenName, yylloc.first_line,ENUM_LEX_##tokenName); 
    int nrLexicalError = 0;
}

%{
    #include  <stdio.h>
    int yycolumn = 1;
    #define YY_USER_ACTION \
        yylloc.first_line = yylloc.last_line = yylineno; \
        yylloc.first_column = yycolumn; \
        yylloc.last_column = yycolumn + yyleng - 1; \
        yycolumn += yyleng;
    void PrintInfo(char *str){
        #ifdef MDEBUG
        printf("[%3d] %10s: %-s\n", yylineno, str, yytext);
        #endif
    }
    void PrintError(char *str){
        printf("Error type A at Line %d: Illegal %s: \"%s\".\n",yylineno,str, yytext);
        nrLexicalError++;
    }
%}
%option yylineno

digit                             [0-9]
digits                            {digit}+
letter_                           [a-zA-Z_]
DEC                               0|([1-9][0-9]*)
OCT                               0([1-7][0-7]*)
HEX                               0x([1-9A-F][0-9A-F]*)
RELOP                             ">"|"<"|">="|"<="|"=="|"!="
TYPE                              int|float
LP                                "("
RP                                ")"
LB                                "["
RB                                "]"
LC                                "{"
RC                                "}"
FLOAT                             {digits}\.{digits}|(\.{digits}|{digits}\.|{digits}\.{digits}|{digits})([eE][+-]?{digits})
FLOATerror                        (\.{digits}|{digits}\.|{digits}\.{digits})([eE][+-]?)
ID                                {letter_}({letter_}|{digit})*
WhiteSpace                        [ \t\r\n]+

%%

"//"                            {
                                    char c = input();
                                    while (c != '\n') c = input();
                                }
"/*"                            {
                                    char c = input();
                                    char pre;
                                    while (!(pre == '*' && c == '/')) {
                                        pre = c;
                                        c = input();
                                    }
                                }
"struct"                        {   PrintInfo("STRUCT");     
                                    CREATELEXNODE(STRUCT)
                                    return STRUCT;      }
"return"                        {   PrintInfo("RETURN");                
                                    CREATELEXNODE(RETURN)
                                    return RETURN;      }
"if"                            {   PrintInfo("IF");                    
                                    CREATELEXNODE(IF)
                                    return IF;          }
"else"                          {   PrintInfo("ELSE");                  
                                    CREATELEXNODE(ELSE)
                                    return ELSE;        }
"while"                         {   PrintInfo("WHILE");                 
                                    CREATELEXNODE(WHILE)
                                    return WHILE;       }
";"                             {   PrintInfo("SEMI");                  
                                    CREATELEXNODE(SEMI)
                                    return SEMI;        }
","                             {   PrintInfo("COMMA");                 
                                    CREATELEXNODE(COMMA)
                                    return COMMA;       }
"="                             {   PrintInfo("ASSIGNOP");              
                                    CREATELEXNODE(ASSIGNOP)
                                    return ASSIGNOP;    }
{RELOP}                         {   PrintInfo("RELOP");                 
                                    CREATELEXNODE(RELOP)
                                    return RELOP;       }
"+"                             {   PrintInfo("PLUS");                  
                                    CREATELEXNODE(PLUS)
                                    return PLUS;        }
"-"                             {   PrintInfo("MINUS");                 
                                    CREATELEXNODE(MINUS)
                                    return MINUS;       }
"*"                             {   PrintInfo("STAR");                  
                                    CREATELEXNODE(STAR)
                                    return STAR;        }
"/"                             {   PrintInfo("DIV");                   
                                    CREATELEXNODE(DIV)
                                    return DIV;         }
"&&"                            {   PrintInfo("AND");                   
                                    CREATELEXNODE(AND)
                                    return AND;         }
"||"                            {   PrintInfo("OR");                    
                                    CREATELEXNODE(OR)
                                    return OR;          }
"."                             {   PrintInfo("DOT");                   
                                    CREATELEXNODE(DOT)
                                    return DOT;         }
"!"                             {   PrintInfo("NOT");                   
                                    CREATELEXNODE(NOT)
                                    return NOT;         }
{TYPE}                          {   PrintInfo("TYPE");                  
                                    CREATELEXNODE(TYPE)
                                    strcpy(yylval->tokenval, yytext);
                                    return TYPE;        }
{LP}                            {   PrintInfo("LP");                    
                                    CREATELEXNODE(LP)
                                    return LP;          }
{RP}                            {   PrintInfo("RP");                    
                                    CREATELEXNODE(RP)
                                    return RP;          }
{LB}                            {   PrintInfo("LB");                    
                                    CREATELEXNODE(LB)
                                    return LB;          }
{RB}                            {   PrintInfo("RB");                    
                                    CREATELEXNODE(RB)
                                    return RB;          }
{LC}                            {   PrintInfo("LC");                    
                                    CREATELEXNODE(LC)
                                    return LC;          }
{RC}                            {   PrintInfo("RC");                    
                                    CREATELEXNODE(RC)
                                    return RC;          }
{FLOAT}                         {   PrintInfo("FLOAT");                 
                                    CREATELEXNODE(FLOAT)
                                    sscanf(yytext, "%lf", &yylval->floatval);
                                    return FLOAT;       }
{FLOATerror}                    {   PrintInfo("FLOATerror");
                                     PrintError("float point number"); 
                                     return FLOAT;      }
{DEC}                           {   PrintInfo("INT");                   
                                    CREATELEXNODE(INT)
                                    sscanf(yytext, "%d", &yylval->intval);
                                    return INT;         }
{OCT}                           {   PrintInfo("INT");                   
                                    CREATELEXNODE(INT)
                                    sscanf(yytext, "%o", &yylval->intval);
                                    return INT;         }
{HEX}                           {   PrintInfo("INT");                   
                                    CREATELEXNODE(INT)
                                    sscanf(yytext, "%i", &yylval->intval);
                                    return INT;         }
"\n"                            {   yycolumn=1;         }

{WhiteSpace}+                   {   /*no action*/       }
{ID}                            {   PrintInfo("ID");                    
                                    CREATELEXNODE(ID)
                                    strcpy(yylval->tokenval, yytext);
                                    return ID;          }
.                               {   PrintError("character");       }

%%
