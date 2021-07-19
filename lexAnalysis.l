%{
#include "y.tab.h"
#include "var.h"
int numLines = 1;  
%}


DIGIT	[0-9]
ID		[a-zA-Z][a-zA-Z0-9]*

%%
<<EOF>>                                             {numLines++;return 0;}
if                                                  {return T_IF;}
else                                                {return T_ELSE;}
for                                                 {return T_FOR;}
while                                               {return T_WHILE;}
return                                              {return T_RETURN;}
break                                               {return T_BREAK;}
continue                                            {return T_CONTINUE;}
true                                                {return T_TURE;}
false                                               {return T_FALSE;}
int|float|double|char|void|bool                     {sprintf(yylval.name,"%s",yytext);return T_TYPE;}
{ID}                                                {sprintf(yylval.name,"%s",yytext);return T_ID;}                                        
"+"                                                 {return T_ADD;}
"-"                                                 {return T_SUB;}
"*"                                                 {return T_MUL;}
"/"                                                 {return T_DIV;}
"%"                                                 {return T_MOD;}
"="                                                 {return T_ASSIGNOP;}
">="                                                {return T_DAYUDENGYU;}
"<="                                                {return T_XIAOYUDENGYU;}
"<"                                                 {return T_XIAOYU;}
">"                                                 {return T_DAYU;}
"!="                                                {return T_UNEQUAL;}
"=="                                                {return T_EQUAL;}
"&&"                                                {return T_AND;}  
"||"                                                {return T_OR;}  
"!"                                                 {return T_NOT;}                                       
{DIGIT}                                             {yylval.symp = symInsert(yytext,"const",atof(yytext));return T_NUM;}
{DIGIT}+                                            {yylval.symp = symInsert(yytext,"const",atof(yytext));return T_NUM;}
{DIGIT}+(\.{DIGIT}+)?(E[+-]?{DIGIT}+)?              {yylval.symp = symInsert(yytext,"const",atof(yytext));return T_DECIMAL;}
"("                                                 {return T_LEFTPAREN;}
"{"                                                 {return T_LEFTBRACE;}
"["                                                 {return T_LEFTBRACKET;}
")"                                                 {return T_RIGHTPAREN;}
"}"                                                 {return T_RIGHTBRACE;}
"]"                                                 {return T_RIGHTBRACKET;}
(\n|\r|\t)                                          {if(*yytext=='\n'){numLines++;}}
[ ]*                                                {}
";"                                                 {return T_SEMICOLON;}
","                                                 {return T_COMMA;}                                            
(\/\/.*)                                            {}
(\".*\")                                            {return T_STRING;}
(\/\*(.|\s|\n|\r)*\*\/)                             {int i=0;while(yytext[i]!='\0'){if(yytext[i]=='\n'){numLines++;}i++;}}
(\.{DIGIT}+)                                        {return T_ERROR;}
%%

int yywrap() {
        return 1;
}

