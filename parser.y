%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <ctype.h>
  int top=-1;
  int flag=0;
  extern char Match_str[20];
  extern char Match_type[20];
  extern char curval[20];
  void yyerror(char *);
  extern FILE *yyin;
  extern int yylineno;
  extern char *yytext;
  void insert_symbol_table_type(char *,char *);
  void insert_symbol_table_value(char *, char *);
  extern int cbracketsopen;
  extern int cbracketsclose;
  extern int bbracketsopen;
  extern int bbracketsclose;
  extern int fbracketsopen;
  extern int fbracketsclose;
  void print_constant_table();
  void print_symbol_table();

  #define YYSTYPE char*
  typedef struct quadruples
  {
    char *op;
    char *arg1;
    char *arg2;
    char *res;
  }quad;
  int quadlen = 0;
  quad q[200];
%}

%start S
%token ID NUM T_lt T_gt T_neq T_and T_or T_incr T_decr T_not T_eq DO WHILE INT CHAR FLOAT VOID H MAINTOK INCLUDE BREAK CONTINUE IF ELSE STRING FOR T_ques T_colon

%token T_pl T_min T_mul T_div
%left T_lt T_gt
%left T_pl T_min
%left T_mul T_div

%%
S
      : START {printf("Input accepted.\n");}
      ;

START
      : INCLUDE T_lt H T_gt MAIN
      | INCLUDE '\"' H '\"' MAIN
      ;

MAIN
      : VOID MAINTOK BODY
      | INT MAINTOK BODY
      ;

BODY
      : '{' C '}'
      ;

C
      : C statement ';'
      | C LOOPS
      | statement ';'
      | LOOPS
      ;

LOOPS
      : WHILE {while1();} '(' COND ')' {while2();} LOOPBODY {while3();}
      | DO {dowhile1();} LOOPBODY WHILE '(' COND ')' {dowhile2();} ';'
      | IF '(' COND ')' {ifelse1();} LOOPBODY {ifelse2();} ELSE LOOPBODY {ifelse3();}
      ;

LOOPBODY
  	  : '{' LOOPC '}'
  	  | ';'
  	  | statement ';'
  	  ;

LOOPC
      : LOOPC statement ';'
      | LOOPC LOOPS
      | statement ';'
      | LOOPS
      ;

statement
      : ASSIGN_EXPR
      | EXP
      ;

COND  : B {codegen_assigna();}
      | B T_and{codegen_assigna();} COND
      | B {codegen_assigna();}T_or COND
      | T_not B{codegen_assigna();}
      ;

B : V T_eq{push();}T_eq{push();} LIT 
  | V T_gt{push();}F
  | V T_lt{push();}F
  | V T_not{push();} T_eq{push();} LIT
  |'(' B ')'
  | V {pushab();}
  ;

F :T_eq{push();}LIT
  |LIT{pusha();}
  ;

V : ID{push();insert_symbol_table_type(Match_str,Match_type);}
  ;

ASSIGN_EXPR
      : LIT {push();} T_eq {push();} EXP {codegen_assign();}
      | TYPE LIT {push();} T_eq {push();} EXP {codegen_assign();}
      ;

EXP
	  : ADDSUB
	  | EXP T_lt {push();} ADDSUB {codegen();}
	  | EXP T_gt {push();} ADDSUB {codegen();}
	  ;

ADDSUB
      : TERM
      | EXP T_pl {push();} TERM {codegen();}
      | EXP T_min {push();} TERM {codegen();}
      ;

TERM
	  : FACTOR
      | TERM T_mul {push();} FACTOR {codegen();}
      | TERM T_div {push();} FACTOR {codegen();}
      ;

FACTOR
	  : LIT
	  | '(' EXP ')'
	  ;

LIT
      : ID {push();insert_symbol_table_type(Match_str,Match_type);}
      | NUM {push();insert_symbol_table_value(Match_str,curval);}
      | FLOAT {push();insert_symbol_table_value(Match_str,curval);}
      | STRING {push();insert_symbol_table_value(Match_str,curval);}
      ;
TYPE
      : INT
      | CHAR
      | FLOAT
      ;


%%

#include "lex.yy.c"
#include<ctype.h>
char stack[100][100];

int temp_i=0;
char tmp_i[3];
char temp[2]="t";
int label[20];
int lnum=0;
int ltop=0;
int l_while=0;

int main(int argc,char *argv[])
{
	yyin = fopen("input2.c","r");
	FILE * fp;
	fp=fopen("input.txt","w");
	if(!yyparse())  //yyparse-> 0 if success
	{
		if((bbracketsopen-bbracketsclose))
		{
        		printf("ERROR: brackets error [\n");
			// yyerror("ERROR: brackets error [\n");
			flag = 1;
    		}
    		if((fbracketsopen-fbracketsclose))
    		{
        		printf("ERROR: brackets error {\n");
			// yyerror("ERROR: brackets error {\n");
			flag = 1;
    		}
    		if((cbracketsopen-cbracketsclose))
    		{
        		printf("ERROR: brackets error (\n");
			// yyerror("ERROR: brackets error (\n");
			flag = 1;
    		}


		if(flag == 0)
		{
			printf("Parsing Complete\n");
			printf("SYMBOL TABLE\n");
			printf("%30s %s\n", " ", "------------");
			print_symbol_table();
			printf("\n\nCONSTANT TABLE\n");
			printf("%30s %s\n", " ", "--------------");
			print_constant_table();
		}
		printf("Quadruple Generation Complete\n");
		printf("---------------------Quadruples-------------------------\n\n");
		printf("Operator \t Arg1 \t\t Arg2 \t\t Result \n");
		int i;
		for(i=0;i<quadlen;i++)
		{
			printf("%-8s \t %-8s \t %-8s \t %-6s \n",q[i].op,q[i].arg1,q[i].arg2,q[i].res);
			fprintf(fp,"%s ",q[i].op);
			if(q[i].arg1==NULL)
				fprintf(fp,"NULL ");
			else
				fprintf(fp,"%s ",q[i].arg1);
			if(q[i].arg2==NULL)
				fprintf(fp,"NULL ");
			else
				fprintf(fp,"%s ",q[i].arg2);
			fprintf(fp,"%s \n",q[i].res);
		}
	}
	else
	{
		printf("Parsing failed\n");
	}

	fclose(yyin);
	fclose(fp);
	return 0;
}

void yyerror(char *s)
{
	printf("Error :%s at %d \n",yytext,yylineno);
}

push()
{
	strcpy(stack[++top],yytext);
}
pusha()
{
	strcpy(stack[++top],"  ");
}
pushab()
{
	strcpy(stack[++top],"  ");
	strcpy(stack[++top],"  ");
	strcpy(stack[++top],"  ");
}
codegen()
{
    strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
    printf("%s = %s %s %s\n",temp,stack[top-2],stack[top-1],stack[top]);
    q[quadlen].op = (char*)malloc(sizeof(char)*strlen(stack[top-1]));
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(stack[top-2]));
    q[quadlen].arg2 = (char*)malloc(sizeof(char)*strlen(stack[top]));
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    strcpy(q[quadlen].op,stack[top-1]);
    strcpy(q[quadlen].arg1,stack[top-2]);
    strcpy(q[quadlen].arg2,stack[top]);
    strcpy(q[quadlen].res,temp);
    quadlen++;
    top-=2;
    strcpy(stack[top],temp);

temp_i++;
}
codegen_assigna()
{
	strcpy(temp,"T");
	sprintf(tmp_i, "%d", temp_i);
	strcat(temp,tmp_i);
	printf("%s = %s %s %s %s\n",temp,stack[top-3],stack[top-2],stack[top-1],stack[top]);
	//printf("%d\n",strlen(stack[top]));
	if(strlen(stack[top])==1)
	{
		//printf("hello");
	
    	char t[20];
		//printf("hello");
		strcpy(t,stack[top-2]);
		strcat(t,stack[top-1]);
		q[quadlen].op = (char*)malloc(sizeof(char)*strlen(t));
    	q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(stack[top-3]));
    	q[quadlen].arg2 = (char*)malloc(sizeof(char)*strlen(stack[top]));
    	q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    	strcpy(q[quadlen].op,t);
    	strcpy(q[quadlen].arg1,stack[top-3]);
    	strcpy(q[quadlen].arg2,stack[top]);
    	strcpy(q[quadlen].res,temp);
    	quadlen++;
	}
	else
	{
		q[quadlen].op = (char*)malloc(sizeof(char)*strlen(stack[top-2]));
    	q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(stack[top-3]));
    	q[quadlen].arg2 = (char*)malloc(sizeof(char)*strlen(stack[top-1]));
    	q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    	strcpy(q[quadlen].op,stack[top-2]);
    	strcpy(q[quadlen].arg1,stack[top-3]);
    	strcpy(q[quadlen].arg2,stack[top-1]);
    	strcpy(q[quadlen].res,temp);
    	quadlen++;
	}
	top-=4;

	temp_i++;
	strcpy(stack[++top],temp);
}

codegen_assign()
{
    printf("%s = %s\n",stack[top-3],stack[top]);
    q[quadlen].op = (char*)malloc(sizeof(char));
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(stack[top]));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(stack[top-3]));
    strcpy(q[quadlen].op,"=");
    strcpy(q[quadlen].arg1,stack[top]);
    strcpy(q[quadlen].res,stack[top-3]);
    quadlen++;
    top-=2;
}


ifelse1()
{
    lnum++;
    strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
    printf("%s = not %s\n",temp,stack[top]);
    q[quadlen].op = (char*)malloc(sizeof(char)*4);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(stack[top]));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    strcpy(q[quadlen].op,"not");
    strcpy(q[quadlen].arg1,stack[top]);
    strcpy(q[quadlen].res,temp);
    quadlen++;
    printf("if %s goto L%d\n",temp,lnum);
    q[quadlen].op = (char*)malloc(sizeof(char)*3);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(temp));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"if");
    strcpy(q[quadlen].arg1,temp);
    char x[10];
    sprintf(x,"%d",lnum);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
    temp_i++;
    label[++ltop]=lnum;
}

ifelse2()
{
    int x;
    lnum++;
    x=label[ltop--];
    printf("goto L%d\n",lnum);
    q[quadlen].op = (char*)malloc(sizeof(char)*5);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"goto");
    char jug[10];
    sprintf(jug,"%d",lnum);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,jug));
    quadlen++;
    printf("L%d: \n",x);
    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(x+2));
    strcpy(q[quadlen].op,"Label");

    char jug1[10];
    sprintf(jug1,"%d",x);
    char l1[]="L";
    strcpy(q[quadlen].res,strcat(l1,jug1));
    quadlen++;
    label[++ltop]=lnum;
}

ifelse3()
{
	int y;
	y=label[ltop--];
	printf("L%d: \n",y);
	q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(y+2));
    strcpy(q[quadlen].op,"Label");
    char x[10];
    sprintf(x,"%d",y);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
	lnum++;
}

dowhile1()
{
	l_while = lnum;
    printf("L%d: \n",lnum++);
    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"Label");
    char x[10];
    sprintf(x,"%d",lnum-1);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
}

dowhile2()
{
	temp_i--;
	strcpy(temp,"T");
 	sprintf(tmp_i, "%d", temp_i);
 	strcat(temp,tmp_i);
    printf("if %s goto L%d\n",temp,lnum-1);
    q[quadlen].op = (char*)malloc(sizeof(char)*3);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(temp));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"if");
    strcpy(q[quadlen].arg1,temp);
    char x[10];
    sprintf(x,"%d",lnum-1);char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;

 	temp_i++;
}


while1()
{

    l_while = lnum;
    printf("L%d: \n",lnum++);
    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"Label");
    char x[10];
    sprintf(x,"%d",lnum-1);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
}

while2()
{
 	strcpy(temp,"T");
 	sprintf(tmp_i, "%d", temp_i);
 	strcat(temp,tmp_i);
 	printf("%s = not %s\n",temp,stack[top]);
    q[quadlen].op = (char*)malloc(sizeof(char)*4);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(stack[top]));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(temp));
    strcpy(q[quadlen].op,"not");
    strcpy(q[quadlen].arg1,stack[top]);
    strcpy(q[quadlen].res,temp);
    quadlen++;
    printf("if %s goto L%d\n",temp,lnum);
    q[quadlen].op = (char*)malloc(sizeof(char)*3);
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(temp));
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"if");
    strcpy(q[quadlen].arg1,temp);
    char x[10];
    sprintf(x,"%d",lnum);char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;

 temp_i++;
 }

while3()
{

	printf("goto L%d \n",l_while);
	q[quadlen].op = (char*)malloc(sizeof(char)*5);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(l_while+2));
    strcpy(q[quadlen].op,"goto");
    char x[10];
    sprintf(x,"%d",l_while);
    char l[]="L";
    strcpy(q[quadlen].res,strcat(l,x));
    quadlen++;
    printf("L%d: \n",lnum++);
    q[quadlen].op = (char*)malloc(sizeof(char)*6);
    q[quadlen].arg1 = NULL;
    q[quadlen].arg2 = NULL;
    q[quadlen].res = (char*)malloc(sizeof(char)*(lnum+2));
    strcpy(q[quadlen].op,"Label");
    char x1[10];
    sprintf(x1,"%d",lnum-1);
    char l1[]="L";
    strcpy(q[quadlen].res,strcat(l1,x1));
    quadlen++;
}

