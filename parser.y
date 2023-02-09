/* -------------------------------------------------------------------------*/
/*                                                                          */
/* This Flex program produces the corresponding C code to execute           */
/* semantic analysis and compile provided SimpleLanguage (.sl) file.        */
/*                                                                          */
/* Author: Aggelos Stamatiou, June 2017                                     */
/*                                                                          */
/* This source code is free software: you can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published by     */
/* the Free Software Foundation, either version 3 of the License, or        */
/* (at your option) any later version.                                      */
/*                                                                          */
/* This software is distributed in the hope that it will be useful,         */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of           */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            */
/* GNU General Public License for more details.                             */
/*                                                                          */
/* You should have received a copy of the GNU General Public License        */
/* along with this source code. If not, see <http://www.gnu.org/licenses/>. */
/* -------------------------------------------------------------------------*/

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sglib.h"

/* Just for being able to show the line number were the error occurs. */
extern FILE *yyout;
extern int   yylineno;
       int   the_errors = 0;
extern int   yylex();
       int   yyerror(const char*);

/* The file that contains all the functions */
#include "jvmSimp.h"
#define  TYPEDESCRIPTOR(TYPE) ((TYPE == type_integer) ? "I" : "F")
%}

/* Output informative error messages (bison Option) */
%define parse.error verbose

/* Declaring the possible types of Symbols*/
%union {
   char *lexical;
   int   intval;
   struct {
	    ParType  type;
	    char    *place;
   } se;
}

/* Token declarations */
%token <lexical>      T_num
%token <lexical>      T_real
%token <lexical>      T_id
%token T_start        "start"
%token T_end          "end"
%token T_print        "print"
%token T_type_integer "int"
%token T_type_float   "float"
%token '('
%token ')'

/* Type declarations */
%type<se> expr
%type<se> printcmd

%%
program:
    "start" T_id {
        create_preample($2);
        symbolTable = NULL;
    }
	stmts "end" {
	    fprintf(yyout, "return \n.end method\n\n");
	}
	;

/* A simple (very) definition of a list of statements.*/
stmts:
      '(' stmt  ')'       {/* nothing */}
    | '(' stmt  ')' stmts {/* nothing */}
    | '(' error ')' stmts
    ;

stmt:
      asmt     {/* nothing */}
	| printcmd {/* nothing */}
	;

printcmd: 
    "print" expr {
        $$.type = $2.type;
		fprintf(yyout, "getstatic java/lang/System/out Ljava/io/PrintStream;\n");
		fprintf(yyout, "swap\n");
		fprintf(yyout, "invokevirtual java/io/PrintStream/println(%s)V\n", TYPEDESCRIPTOR($2.type));
	}
	;

asmt: 
    T_id expr {
	    if(lookup_type($1) == type_real && $2.type == type_integer) {
	        fprintf(yyout,"i2f\n");
	    } else if(lookup_type($1) == type_integer && $2.type == type_real) {
		    printf("Integer var %s. ", $1);
		    yyerror("Narrowing Conversion (float to int)");
		}
	    fprintf(yyout, "%sstore %d\n", typePrefix(lookup_type($1)), lookup_position($1));
	}
	;

expr:  
    T_num {
        $$.type = type_integer;
        fprintf(yyout, "sipush %s\n", $1);
    }
	| T_real {
	    $$.type = type_real;
	    fprintf(yyout, "ldc %s\n", $1);
	}
	| T_id {
	    if (!($$.type = lookup_type($1))) {
	  	    printf("Variable %s NOT initialized, in line %d. ", $1, yylineno);
		    yyerror("Variable fault");
		    $$.type = type_error;
		} else {
		    fprintf(yyout, "%sload %d\n", typePrefix($$.type), lookup_position($1));
		}
    }
	| '(' "int" expr ')' {
	    if($3.type != type_integer) {
	        $$.type = type_integer;
	        fprintf(yyout,"f2i\n");
	    } else if($3.type == type_error) {
	        $$.type = type_error;
	    } else {
	        $$.type = type_integer;
	        if(the_errors != 0) {
			    printf("Warning: value is already int, in line %d.\n", yylineno);
			}
		}
	}
	| '(' "float" expr ')' {
	    if($3.type != type_real) {
	        $$.type = type_real;
	        fprintf(yyout, "f2i\n");
	    } else if($3.type == type_error) {
	        $$.type = type_error;
	    } else {
	        $$.type = type_real;
	        if(the_errors != 0) {
			    printf("Warning: value is already real, in line %d.\n", yylineno);
			}
	    }
	}
	| '(' expr ')' {
	    if($2.type == type_error) {
	        $$.type = type_error;
	    } else{
	        $$.type = $2.type;
	    }
	}
	| expr expr '+' {
	    if($1.type == type_error || $2.type == type_error) {
	        $$.type = type_error;
	    } else {
	        $$.type = typeDefinition($1.type, $2.type);
			if($1.type == type_integer && $2.type == type_real) {
			    fprintf(yyout, "swap\ni2f\nswap\n");
			} else if($1.type == type_real && $2.type == type_integer) {
			    fprintf(yyout, "i2f\n");
			}
		    fprintf(yyout, "%sadd \n", typePrefix($$.type));
	    }
	}
	| expr expr '*' {
	    if($1.type == type_error || $2.type == type_error) {
	        $$.type = type_error;
	    } else{
	        $$.type = typeDefinition($1.type, $2.type);
			fprintf(yyout, "%smul \n", typePrefix($$.type));
	    }
	}
 	;
%%

/* The usual yyerror */
int yyerror(const char *msg)
{
  printf("ERROR: %s. on line %d.\n", msg, yylineno);
  the_errors++;
}

/* The lexer... */
#include "lexer.c"

int main(int argc, char **argv)
{
    /* skip over program name */
    ++argv, --argc;
    if (argc > 0) {
        yyin = fopen(argv[0], "r" );
    } else {
        yyin = stdin;
    }
    if (argc > 1) {
        yyout = fopen(argv[1], "w");
    } else {
	    yyout = stdout;
    }

    int result = yyparse();
    printf("Errors found %d.\n", the_errors);
    fclose(yyout);
    if (the_errors != 0 && yyout != stdout) {
        remove(argv[1]);
        printf("No Code Generated.\n");
        exit(1);
    }

    return result;
}
