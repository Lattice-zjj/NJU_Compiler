%top{
    #include <stdint.h>
    #include <inttypes.h>
    #include <string.h>
    #include "myTree.h"
    #define YYSTYPE Node*
    #include "syntax.tab.h"
    //#define MDEBUG 
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
    void print4Debug(char *str){
        #ifdef MDEBUG
        printf("[%3d] %10s: %-s\n", yylineno, str, yytext);
        #endif
    }
    void printError(){
        printf("Error type A at Line %d: Mysterious characters \"%s\".\n",yylineno, yytext);
        nrLexicalError++;
    }
    char* up2low(char *str){
        for(int i=0;i<strlen(str);i++){
            if(str[i]>='A' && str[i] <= 'Z')
                str[i] += 'a'-'A';
        }
        return str;
    }
%}
%option yylineno

digit                             [0-9]
digits                            {digit}+
letter_                           [a-zA-Z_]
DEC                               0|([1-9][0-9]*)
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

"//".*                          {print4Debug("Some Comment");}
"struct"                        {   print4Debug("STRUCT");     
                                    CREATELEXNODE(STRUCT)
                                    return STRUCT;      }
"return"                        {   print4Debug("RETURN");                
                                    CREATELEXNODE(RETURN)
                                    return RETURN;      }
"if"                            {   print4Debug("IF");                    
                                    CREATELEXNODE(IF)
                                    return IF;          }
"else"                          {   print4Debug("ELSE");                  
                                    CREATELEXNODE(ELSE)
                                    return ELSE;        }
"while"                         {   print4Debug("WHILE");                 
                                    CREATELEXNODE(WHILE)
                                    return WHILE;       }
";"                             {   print4Debug("SEMI");                  
                                    CREATELEXNODE(SEMI)
                                    return SEMI;        }
","                             {   print4Debug("COMMA");                 
                                    CREATELEXNODE(COMMA)
                                    return COMMA;       }
"="                             {   print4Debug("ASSIGNOP");              
                                    CREATELEXNODE(ASSIGNOP)
                                    return ASSIGNOP;    }
{RELOP}                         {   print4Debug("RELOP");                 
                                    CREATELEXNODE(RELOP)
                                    return RELOP;       }
"+"                             {   print4Debug("PLUS");                  
                                    CREATELEXNODE(PLUS)
                                    return PLUS;        }
"-"                             {   print4Debug("MINUS");                 
                                    CREATELEXNODE(MINUS)
                                    return MINUS;       }
"*"                             {   print4Debug("STAR");                  
                                    CREATELEXNODE(STAR)
                                    return STAR;        }
"/"                             {   print4Debug("DIV");                   
                                    CREATELEXNODE(DIV)
                                    return DIV;         }
"&&"                            {   print4Debug("AND");                   
                                    CREATELEXNODE(AND)
                                    return AND;         }
"||"                            {   print4Debug("OR");                    
                                    CREATELEXNODE(OR)
                                    return OR;          }
"."                             {   print4Debug("DOT");                   
                                    CREATELEXNODE(DOT)
                                    return DOT;         }
"!"                             {   print4Debug("NOT");                   
                                    CREATELEXNODE(NOT)
                                    return NOT;         }
{TYPE}                          {   print4Debug("TYPE");                  
                                    CREATELEXNODE(TYPE)
                                    strcpy(yylval->tokenval, yytext);
                                    return TYPE;        }
{LP}                            {   print4Debug("LP");                    
                                    CREATELEXNODE(LP)
                                    return LP;          }
{RP}                            {   print4Debug("RP");                    
                                    CREATELEXNODE(RP)
                                    return RP;          }
{LB}                            {   print4Debug("LB");                    
                                    CREATELEXNODE(LB)
                                    return LB;          }
{RB}                            {   print4Debug("RB");                    
                                    CREATELEXNODE(RB)
                                    return RB;          }
{LC}                            {   print4Debug("LC");                    
                                    CREATELEXNODE(LC)
                                    return LC;          }
{RC}                            {   print4Debug("RC");                    
                                    CREATELEXNODE(RC)
                                    return RC;          }
{FLOAT}                         {   print4Debug("FLOAT");                 
                                    CREATELEXNODE(FLOAT)
                                    sscanf(yytext, "%lf", &yylval->floatval);
                                    return FLOAT;       }
{FLOATerror}                    {   print4Debug("FLOATerror");
                                    printError(); 
                                    return FLOAT;      }
{DEC}                           {   print4Debug("INT");                   
                                    CREATELEXNODE(INT)
                                    sscanf(yytext, "%d", &yylval->intval);
                                    return INT;         }
"\n"                            {   yycolumn=1;         }
{WhiteSpace}+                   {   /*no action*/       }
{ID}                            {   print4Debug("ID");                    
                                    CREATELEXNODE(ID)
                                    strcpy(yylval->tokenval, yytext);
                                    return ID;          }
.                               {   printError();       }

%%
