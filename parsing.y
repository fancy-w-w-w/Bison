%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "var.h"


int yylex();
int nowTable=0;
int maxTable = 0;
int nextinstr = 100;
int ncodes = 0;
int tmpVal = 0;
int nts=0;
int params=0;
void yyerror(const char* msg);
extern FILE *yyin;
extern int numLines;
%}

%union {
        char name[256];
        char *namePtr;
        double dval;
        struct symbol *symp;
        struct translate *attr;
        int instr;
}

%token T_TURE
%token T_FALSE
%token <name> T_TYPE
%token <name> T_ID
%token T_ADD
%token T_SUB
%token T_MUL
%token T_DIV
%token T_MOD
%token T_ASSIGNOP
%token T_DAYUDENGYU
%token T_XIAOYUDENGYU
%token T_XIAOYU
%token T_DAYU
%token T_AND     
%token T_OR                                                  
%token <symp> T_NUM
%token T_LEFTPAREN
%token T_LEFTBRACE
%token T_LEFTBRACKET
%token T_RIGHTPAREN
%token T_RIGHTBRACE
%token T_RIGHTBRACKET
%token T_SEMICOLON
%token T_COMMA                                            
%token T_STRING
%token <symp> T_DECIMAL
%token T_NOT
%token T_IF
%token T_ELSE
%token T_WHILE
%token T_FOR
%token T_RETURN
%token T_EQUAL
%token T_UNEQUAL
%token T_ERROR
%token T_BREAK
%token T_CONTINUE

%nonassoc T_ID
%left T_COMMA
%right T_ASSIGNOP
%left T_OR
%left T_AND
%left T_EQUAL T_UNEQUAL
%nonassoc T_DAYUDENGYU T_XIAOYUDENGYU T_XIAOYU T_DAYU

%left T_ADD T_SUB
%left T_MUL T_DIV T_MOD
%right  T_NOT 
%right UMINUS
%left T_LEFTPAREN T_RIGHTPAREN
%left T_LEFTBRACKET T_RIGHTBRACKET

%type <attr> expression if_stmt while_loop N other statements block func_call
%type <instr> M



%%

start           :  program {printf("\n\nsuccess\n\n");}    
                ;

program         :  func program            {}               
                |  declares program        {}
                |                          {}
                ;

expression      :  expression T_ADD expression           {$$=&ts[nts];nts++;sprintf($$->name,"t%d",tmpVal);tmpVal++;char c[2000];sprintf(c,"%s=%s+%s",$$->name,$1->name,$3->name);genCodes(c);}
                |  expression T_SUB expression           {$$=&ts[nts];nts++;sprintf($$->name,"t%d",tmpVal);tmpVal++;char c[2000];sprintf(c,"%s=%s+%s",$$->name,$1->name,$3->name);genCodes(c);}
                |  expression T_MUL expression           {$$=&ts[nts];nts++;sprintf($$->name,"t%d",tmpVal);tmpVal++;char c[2000];sprintf(c,"%s=%s+%s",$$->name,$1->name,$3->name);genCodes(c);}
                |  expression T_DIV expression           {$$=&ts[nts];nts++;sprintf($$->name,"t%d",tmpVal);tmpVal++;char c[2000];sprintf(c,"%s=%s+%s",$$->name,$1->name,$3->name);genCodes(c);}
                |  expression T_MOD expression           {$$=&ts[nts];nts++;sprintf($$->name,"t%d",tmpVal);tmpVal++;char c[2000];sprintf(c,"%s=%s+%s",$$->name,$1->name,$3->name);genCodes(c);}
                |  expression T_AND M expression         {$$=&ts[nts];nts++;backPatch($1->trueList,$1->tTop,$3);merge($$->falseList,&($$->fTop),$1->falseList,$1->fTop,$4->falseList,$4->fTop);assign($$->trueList,&($$->tTop),$4->trueList,$4->tTop);}
                |  expression T_OR M expression          {$$=&ts[nts];nts++;backPatch($1->falseList,$1->fTop,$3);merge($$->trueList,&($$->tTop),$1->trueList,$1->tTop,$4->trueList,$4->tTop);assign($$->falseList,&($$->fTop),$4->falseList,$4->fTop);}
                |  expression T_DAYU expression          {$$=&ts[nts];nts++;$$->trueList[$$->tTop]=nextinstr;($$->tTop)++;char c[2000];sprintf(c,"if %s>%s goto ",$1->name,$3->name);genCodes(c);$$->falseList[$$->fTop]=nextinstr;($$->fTop)++;genCodes("goto ");}
                |  expression T_DAYUDENGYU expression    {$$=&ts[nts];nts++;$$->trueList[$$->tTop]=nextinstr;($$->tTop)++;char c[2000];sprintf(c,"if %s>=%s goto ",$1->name,$3->name);genCodes(c);$$->falseList[$$->fTop]=nextinstr;($$->fTop)++;genCodes("goto ");}
                |  expression T_XIAOYU expression        {$$=&ts[nts];nts++;$$->trueList[$$->tTop]=nextinstr;($$->tTop)++;char c[2000];sprintf(c,"if %s<%s goto ",$1->name,$3->name);genCodes(c);$$->falseList[$$->fTop]=nextinstr;($$->fTop)++;genCodes("goto ");}
                |  expression T_XIAOYUDENGYU expression  {$$=&ts[nts];nts++;$$->trueList[$$->tTop]=nextinstr;($$->tTop)++;char c[2000];sprintf(c,"if %s<=%s goto ",$1->name,$3->name);genCodes(c);$$->falseList[$$->fTop]=nextinstr;($$->fTop)++;genCodes("goto ");}
                |  expression T_EQUAL expression         {$$=&ts[nts];nts++;$$->trueList[$$->tTop]=nextinstr;($$->tTop)++;char c[2000];sprintf(c,"if %s==%s goto ",$1->name,$3->name);genCodes(c);$$->falseList[$$->fTop]=nextinstr;($$->fTop)++;genCodes("goto ");}
                |  expression T_UNEQUAL expression       {$$=&ts[nts];nts++;$$->trueList[$$->tTop]=nextinstr;($$->tTop)++;char c[2000];sprintf(c,"if %s!=%s goto ",$1->name,$3->name);genCodes(c);$$->falseList[$$->fTop]=nextinstr;($$->fTop)++;genCodes("goto ");}
                |  T_ID T_ASSIGNOP expression            {if (symlook($1)==-1){char e[500];sprintf(e,"Not declared Variable: %s!",$1);yyerror(e);}$$=&ts[nts];nts++;char c[600];sprintf(c,"%s=%s",$1,$3->name);genCodes(c);}
                |  T_LEFTPAREN expression T_RIGHTPAREN   {$$=&ts[nts];nts++;sprintf($$->name,"%s",$2->name);assign($$->falseList,&($$->fTop),$2->falseList,$2->fTop);assign($$->trueList,&($$->tTop),$2->trueList,$2->tTop);}
                |  T_SUB expression %prec UMINUS         {$$=&ts[nts];nts++;sprintf($$->name,"t%d",tmpVal);tmpVal++;char c[600];sprintf(c,"%s=-%s",$$->name,$2->name);genCodes(c);}
                |  T_NOT expression                      {$$=&ts[nts];nts++;assign($$->trueList,&($$->tTop),$2->falseList,$2->fTop);assign($$->falseList,&($$->fTop),$2->trueList,$2->tTop);}
                |  T_ID                                  {if (symlook($1)==-1){char e[500];sprintf(e,"Not declared Variable: %s!",$1);yyerror(e);}$$=&ts[nts];nts++;sprintf($$->name,"%s",$1);}
                |  func_call                             {$$=&ts[nts];nts++;char t[5];sprintf($$->name,"t%d",tmpVal);tmpVal++;char c[2000];sprintf(c,"%s = call %s, %d",$$->name,$1->name,params);genCodes(c);params=0;}
                |  T_DECIMAL                             {$$=&ts[nts];nts++;sprintf($$->name,"%s",$1->name);}
                |  T_NUM                                 {$$=&ts[nts];nts++;sprintf($$->name,"%s",$1->name);}
                |  T_TURE                                {$$=&ts[nts];nts++;$$->trueList[$$->tTop]=nextinstr;($$->tTop)++;genCodes("goto ");}
                |  T_FALSE                               {$$=&ts[nts];nts++;$$->falseList[$$->fTop]=nextinstr;($$->fTop)++;genCodes("goto ");}
                |  T_STRING                              {}
                ;
                 
M               :                                        {$$=nextinstr;}
                ;

statements      :  M expression T_SEMICOLON statements              {$$=&ts[nts];nts++;$$->nextList[$$->nTop]=$1;($$->nTop)++;/*assign($$->nextList,&($$->nTop),$4->nextList,$4->nTop);*/}
                |  if_stmt M statements                             {$$=&ts[nts];nts++;assign($$->nextList,&($$->nTop),$3->nextList,$3->nTop);backPatch($1->nextList,$1->nTop-1,$2);backPatch($1->falseList,$1->fTop-1,$2);}
                |  while_loop M statements                          {$$=&ts[nts];nts++;assign($$->nextList,&($$->nTop),$3->nextList,$3->nTop);backPatch($1->nextList,$1->nTop,$2);}
                |  for_loop statements                              {$$=&ts[nts];nts++;assign($$->nextList,&($$->nTop),$2->nextList,$2->nTop);}
                |  declares statements                              {$$=&ts[nts];nts++;assign($$->nextList,&($$->nTop),$2->nextList,$2->nTop);}
                |  T_RETURN expression T_SEMICOLON statements       {$$=&ts[nts];nts++;assign($$->nextList,&($$->nTop),$4->nextList,$4->nTop);char c[300];sprintf(c,"return %s",$2->name);genCodes(c);}
                |  T_BREAK T_SEMICOLON statements                   {}
                |  T_CONTINUE T_SEMICOLON statements                {}
                |                                                   {$$=&ts[nts];nts++;$$->nextList[$$->nTop]=nextinstr;($$->nTop)++;}
                ;

block           :  T_LEFTBRACE statements T_RIGHTBRACE  {$$=&ts[nts];nts++;assign($$->nextList,&($$->nTop),$2->nextList,$2->nTop);}
                ;

func            :  T_TYPE T_ID {symInsert($2,"func",0);pushTable($2);char c[300];sprintf(c,"%s:",$2);genCodes(c);} T_LEFTPAREN parameters T_RIGHTPAREN block {popTable();}
                ;

parameters      :  parameter T_TYPE T_ID  {symInsert($3,$2,0);}
                |  {}
                ;

parameter       :  parameter T_TYPE T_ID T_COMMA  {symInsert($3,$2,0);}
                |  {}
                ;

func_call       :  T_ID {params=0;} T_LEFTPAREN call_parameters T_RIGHTPAREN  {$$=&ts[nts];nts++;if (symlook($1)==-1){yyerror("function is not declared");}sprintf($$->name,"%s",$1);}
                ;

call_parameters :   expression call_parameter{params++;char c[300];sprintf(c,"param %s",$1->name);genCodes(c);}
                |    {}
                ;

call_parameter  :  T_COMMA expression  call_parameter{params++;char c[300];sprintf(c,"param %s",$2->name);genCodes(c);}
                |   {}
                ;


while_loop      :  T_WHILE M T_LEFTPAREN expression T_RIGHTPAREN M other{$$=&ts[nts];nts++;backPatch($4->trueList,$4->tTop,$6);assign($$->nextList,&($$->nTop),$4->falseList,$4->fTop);char c[500];sprintf(c,"goto %d",$2);genCodes(c);}
                ; 

for_loop        :  T_FOR T_LEFTPAREN for_exp T_SEMICOLON for_exp T_SEMICOLON for_exp T_RIGHTPAREN other {}
                ;

for_exp         :  expression for_other{}
                |{}
                ;

for_other       :  for_other T_COMMA expression{}
                |{}
                ;

if_stmt         :  T_IF T_LEFTPAREN expression T_RIGHTPAREN M other N T_ELSE M other {$$=&ts[nts];nts++;backPatch($3->trueList,$3->tTop,$5);backPatch($3->falseList,$3->fTop,$9);struct translate tmp;merge(tmp.nextList,&(tmp.nTop),$6->nextList,$6->nTop,$7->nextList,$7->nTop);merge($$->nextList,&($$->nTop),tmp.nextList,tmp.nTop,$10->nextList,$10->nTop);}
                |  T_IF T_LEFTPAREN expression T_RIGHTPAREN M other {$$=&ts[nts];nts++;backPatch($3->trueList,$3->tTop,$5);merge($$->nextList,&($$->nTop),$3->falseList,$3->fTop,$6->nextList,$6->nTop);}
                ;

N               :  {$$=&ts[nts];nts++;$$->trueList[$$->tTop]=nextinstr;($$->tTop)++;genCodes("goto ");}  
                ;
other           :  block                       {$$=&ts[nts];nts++;assign($$->nextList,&($$->nTop),$1->nextList,$1->nTop);}
                |  T_BREAK T_SEMICOLON         {}
                |  T_CONTINUE T_SEMICOLON      {}
                ;

declares        :  declare T_SEMICOLON          
                ;

declare         :  declare T_COMMA T_ID  {symInsert($3,sTables[nowTable].sym[sTables[nowTable].top-1].type,0);}
                |  T_TYPE T_ID           {symInsert($2,$1,0);}
                ;

%%

void yyerror(const char* msg) {
        printf("At %d line,an error has been checked\n",numLines);
        printf("%s\n",msg);
        exit(1);
}

int symlook(char *name)
{
    int now = nowTable;
    while(now!=-1){
        for (int j=0;j<sTables[now].top;j++){
            if (!strcmp(sTables[now].sym[j].name, name))
            {
                return j;
            }
        }
        now = sTables[now].pre;
    }
    return -1;
}

int symLookNow(char *name){
    for (int j=0;j<sTables[nowTable].top;j++)
        if (!strcmp(sTables[nowTable].sym[j].name, name))
        {
            return j;
        }
    return -1;
}

void pushTable(char *name){
    int tmp;
    if (nowTable==200){
        yyerror("symbol tables stack is full!\n");
    }else{
        maxTable++;
        tmp = nowTable;
        nowTable = maxTable;
        sTables[nowTable].top = 0;
        sTables[nowTable].pre = tmp;
        sprintf(sTables[nowTable].name,"%s",name);
    }
}

void popTable(){
    nowTable = sTables[nowTable].pre;
}

struct symbol *symInsert(char *name,char *type,double value)
{
    if (sTables[nowTable].top==201){
        return NULL;
    }
    int p = symLookNow(name);
    if (p==-1){
        sprintf(sTables[nowTable].sym[sTables[nowTable].top].name,"%s",name);
        sprintf(sTables[nowTable].sym[sTables[nowTable].top].type,"%s",type);
        sTables[nowTable].sym[sTables[nowTable].top].value = value;
        sTables[nowTable].top++;
        return &(sTables[nowTable].sym[sTables[nowTable].top-1]);
    }else{
        return &(sTables[nowTable].sym[p]);
    }
    return NULL;
}

void symUpdate(char *name,char *type,double value)
{
    int p;
    p = symlook(name);
    if (p!=-1){
        sprintf(sTables[nowTable].sym[p].name,"%s",name);
        sprintf(sTables[nowTable].sym[p].type,"%s",type);
        sTables[nowTable].sym[p].value = value;
        return;
    }
    yyerror("symbol not existed");
    return;
}

void genCodes(char* code){
    IntermediateLanguage[ncodes].no = nextinstr;
    sprintf(IntermediateLanguage[ncodes].sentence,"%s",code);
    nextinstr++;
    ncodes++;
}

void backPatch(int *b,int n,int m){
    for (int i=0;i<n;i++){
        for (int j=0;j<ncodes;j++){
            if (IntermediateLanguage[j].no == *(b+i)){
                sprintf(IntermediateLanguage[j].sentence,"%s%d",IntermediateLanguage[j].sentence,m);
                break;
            }
        }
    }
}
void merge(int *a,int *na,int *b,int nb,int *c,int nc){
    int i=0;
    int j=0;
    while (i<nb){
        *(a+*na) = *(b+i);
        (*na)++;
        i++;
    }
     while (j<nc){
        *(a+*na) = *(c+j);
        (*na)++;
        j++;
    }
}
void assign(int *a,int *na,int *b,int nb){
    int i=0;
    while (i<nb){
        *(a+*na) = *(b+i);
        (*na)++;
        i++;
    }
}

int main(int argc,char *argv[]) {
    for(int i=0;i<1000;i++){
        ts[i].tTop=0;
        ts[i].fTop=0;
        ts[i].nTop=0;
    }
     for(int i=0;i<200;i++){
        sTables[i].top=0;
        sTables[i].pre=-1;
    }
    sTables[nowTable].top = 0;
    sprintf(sTables[nowTable].name,"%s","global");
    symInsert("Print","func",0);
    if (argc==2){
            yyin=fopen(argv[1],"r");
    }
    int result = yyparse();
    
    printSym();
    printf("the intermediate language:\n");
    for (int i=0;i<ncodes;i++){
        printf("%d: %s\n",IntermediateLanguage[i].no,IntermediateLanguage[i].sentence);
    }
    return result;
}

void printSym(){
    for (int i=0;i<=maxTable;i++){
        printf("symbol table of %s:\n",sTables[i].name);
        printf("No. %d  pre: %d\n",i,sTables[i].pre);
        for (int j=0;j<sTables[i].top;j++)
            printf("%-15s%-15s%-15lf\n",sTables[i].sym[j].name,sTables[i].sym[j].type,sTables[i].sym[j].value);
        printf("*********************\n\n");
    }
}