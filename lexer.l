%{
    #include<string.h>
    #include<stdio.h>
    int line = 0;
    #define YYSTYPE char *
    
    struct symbol_table {
        char type[100];
        char name[100];
	char Class[100];
	char value[100];
	int line_number;
        int valid;
    }st[501];

    struct constant_table {
        char type[100];
        char name[100];
        int valid;
    }ct[501];

	void insert_symbol_table_line(char *str1, int line)
	{
		for(int i = 0 ; i < 501 ; i++)
		{
			if(strcmp(st[i].name,str1)==0)
			{
				st[i].line_number = line;
			}
		}
	}

    	int hash_function(char *str)
	{
		int value = 0;
		for(int i = 0 ; i < strlen(str) ; i++)
		{
			value = 10*value + (str[i] - 'A');
			value = value % 501;
			while(value < 0)
				value = value + 501;
		}
		return value;
	}
	int lookup_symbolTable(char *str)
	{
		int value = hash_function(str);
		if(st[value].valid == 0)
		{
			return 0;
		}
		else if(strcmp(st[value].name,str)==0)
		{
			return 1;
		}
		else
		{
			for(int i = value + 1 ; i!=value ; i = (i+1)%501)
	    	{
	    		if(strcmp(st[i].name,str)==0)
	    		{
	    			return 1;
	    		}
	    	}
	    	return 0;
	    }
	}
	int lookup_constantTable(char *str)
	{
		int value = hash_function(str);
		if(ct[value].valid == 0)
		{
			return 0;
		}
		else if(strcmp(ct[value].name,str)==0)
		{
			return 1;
		}
		else
		{
			for(int i = value + 1 ; i!=value ; i = (i+1)%501)
			{
				if(strcmp(ct[i].name,str)==0)
				{
					return 1;
				}
			}
			return 0;
		}
	}
	void insert_symbolTable(char *str1, char *str2)
	{
		if(lookup_symbolTable(str1))
		{
		    return;
	    	}
		else
		{
			int value = hash_function(str1);
			if(st[value].valid == 0)
			{
				strcpy(st[value].name,str1);
				strcpy(st[value].Class, str2);
				st[value].valid = strlen(str1);
				insert_symbol_table_line(str1, yylineno);
				return;
			}

			int pos = 0;

			for (int i = value + 1 ; i!=value ; i = (i+1)%501)
			{
				if(st[i].valid == 0)
				{
					pos = i;
					break;
				}
			}

			strcpy(st[pos].name,str1);
			strcpy(st[pos].Class,str2);
			st[pos].valid = strlen(str1);
		}
	}

	void insert_symbol_table_type(char *str1, char *str2)
	{
		for(int i = 0 ; i < 501 ; i++)
		{
			if(strcmp(st[i].name,str1)==0)
			{	
				strcpy(st[i].type,str2);
			}
		}
   	}

	void insert_symbol_table_value(char *str1, char *str2)
	{
		for(int i = 0 ; i < 501 ; i++)
		{
			if(strcmp(st[i].name,str1)==0)
			{
				strcpy(st[i].value,str2);
			}
		}
	}

	
	void insert_constantsTable(char *str1, char *str2)
	{
		if(lookup_constantTable(str1))
			return;
		else
		{
			int value = hash_function(str1);
			if(ct[value].valid == 0)
			{
				strcpy(ct[value].name,str1);
				strcpy(ct[value].type,str2);
				ct[value].valid = strlen(str1);
				return;
			}

			int pos = 0;

			for (int i = value + 1 ; i!=value ; i = (i+1)%501)
			{
				if(ct[i].valid == 0)
				{
					pos = i;
					break;
				}
			}

			strcpy(ct[pos].name,str1);
			strcpy(ct[pos].type,str2);
			ct[pos].valid = strlen(str1);
		}
	}

	void print_symbol_table()
	{
		printf("%10s | %15s | %10s | %10s | %10s\n","SYMBOL", "CLASS", "TYPE","VALUE", "LINE NO");
		for(int i=0;i<81;i++) {
			printf("-");
		}
		printf("\n");
		for(int i = 0 ; i < 501 ; i++)
		{
			if(st[i].valid == 0)
			{
				continue;
			}
			printf("%10s | %15s | %10s | %10s | %10d\n",st[i].name, st[i].Class, st[i].type, st[i].value, st[i].line_number);
		}
    	}

	void print_constant_table()
	{
		printf("%10s | %15s\n","NAME", "TYPE");
		for(int i=0;i<81;i++) {
			printf("-");
		}
		printf("\n");
		for(int i = 0 ; i < 501 ; i++)
		{
			if(ct[i].valid == 0)
				continue;

			printf("%10s | %15s\n",ct[i].name, ct[i].type);
		}
	}

    int cbracketsopen = 0;
    int cbracketsclose = 0;
    int bbracketsopen = 0;
    int bbracketsclose = 0;
    int fbracketsopen = 0;
    int fbracketsclose = 0;

	char Match_str[20];
	char Match_type[20];
	char curval[20];
%}

alpha [A-Za-z_]
digit [0-9]
%option yylineno
%%
\/\/(.*) ;
[ \t\n] ;
"{" {fbracketsopen++;return('{');}
"}" {fbracketsclose++;return('}');}
"(" {cbracketsopen++;return('(');}
")" {cbracketsclose++;return(')');}
"[" {bbracketsopen++;return('[');}
"]" {bbracketsopen++;return(']');}
":" {return T_colon;}
"?" {return T_ques;}
"do" {insert_symbolTable(yytext, "KEYWORD");return DO;}
"while" {insert_symbolTable(yytext, "KEYWORD");return WHILE;}
"for" {insert_symbolTable(yytext, "KEYWORD");return FOR;}
"if" {insert_symbolTable(yytext, "KEYWORD");return IF;}
"else" {insert_symbolTable(yytext, "KEYWORD");return ELSE;}
"break" {insert_symbolTable(yytext, "KEYWORD");return BREAK;}
"continue" {insert_symbolTable(yytext, "KEYWORD");return CONTINUE;}
"int" {insert_symbolTable(yytext, "KEYWORD");strcpy(Match_type, yytext);return INT;}
"float" {insert_symbolTable(yytext, "KEYWORD");strcpy(Match_type, yytext);return FLOAT;}
"char" {insert_symbolTable(yytext, "KEYWORD");strcpy(Match_type, yytext);return CHAR;}
"void" {insert_symbolTable(yytext, "KEYWORD");return VOID;}
"#include" {return INCLUDE;}
"main()" {insert_symbolTable(yytext, "KEYWORD");return MAINTOK;}
{digit}+    {insert_constantsTable(yytext, "NUMERICAL CONSTANT");strcpy(curval, yytext);return NUM;}
{digit}+.{digit}+ {insert_constantsTable(yytext, "FLOAT CONSTANT");strcpy(curval, yytext);return FLOAT;}
{alpha}({alpha}|{digit})* {insert_symbolTable(yytext, "Identifier");strcpy(Match_str, yytext);return ID;}
{alpha}({alpha}|{digit})*"\.h"?  {return H;}
\".*\" {insert_constantsTable(yytext, "CHAR CONSTANT");strcpy(curval, yytext);return STRING;}
"<" {return T_lt;}
">"     {return T_gt;}
"="     {return T_eq;}
"+"     {return T_pl;}
"-"     {return T_min;}
"*"     {return T_mul;}
"/"     {return T_div;}
"++"    {return T_incr;}
"--"    {return T_decr;}
"!"     {return T_neq;}
"||"    {return T_or;}
"&&"    {return T_and;}

.    return yytext[0];

%%

int yywrap(){
    return(1);
}
