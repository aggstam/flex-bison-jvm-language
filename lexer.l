/* -------------------------------------------------------------------------*/
/*                                                                          */
/* This Flex program produces the corresponding C code to validate          */
/* the syntax of provided SimpleLanguage (.sl) file.                        */
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
#include <stdlib.h>
#include <string.h>
%}

%option yylineno

D        [0-9]
LETTER   [a-zA-Z]
VARIABLE {LETTER}({LETTER}|{D}|_)*
FLOAT    {D}+\.{D}*
newline  \n|\x0A|\x0D\x0A

%%
"start"    {return T_start;}
"end"      {return T_end;}
"print"    {return T_print;}
"int"      {return T_type_integer;}
"float"    {return T_type_float;}
"+"        {return '+';}
"*"        {return '*';}
"("        {return '(';}
")"        {return ')';}
"/"        {return '/';}
"-"        {return '-';}
{D}+       {yylval.lexical = strdup(yytext); return T_num;}
{FLOAT}    {yylval.lexical = strdup(yytext); return T_real;}
{VARIABLE} {yylval.lexical = strdup(yytext); return T_id;}
{newline}  { /* yylineno used instead*/ }
[ \t]      { /* nothing */ }
.          {	
                /* A simple error message! */ 
                printf("Lexical Analysis: Unexpected String! :: %s. in line %d. \n", yytext, yylineno);
           }
%%
