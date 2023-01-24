/* File: jvmSimp.h
   File that is to be included in .y parser file that provides
   some useful functions.
*/
/* Definition of the supported types*/
typedef enum {type_error, type_integer, type_real, type_boolean} ParType;

/* #ifdef PARSER */
/* SYMBOL TABLE CODE *************************************************/
#define MAX_VAR_LEN 80
/* The following is the element of the symbol table. For simpicity reasons the symbol table is a linked list.
A variable contains the name (as found on the sourxe file), a type (type_integer,type real) and a position in
the local varaiables space (JVM). */
typedef struct st_var {
	char *varname;
	ParType vartype;
	int position; /*Its position on the variable environment of JVM.*/
	struct st_var *next_st_var;
	} ST_ENTRY;

typedef ST_ENTRY *ST_TABLE;
/* definition required by the Lib (sglib.h ) for the linked lists used in the symbol table.  */
#define ST_COMPARATOR(e1,e2) (strcmp(e1->varname,e2->varname))



/* Functions Needed*/

int addvar(char *VariableName,ParType TypeDecl);
int lookup(char *VariableName);
ParType lookup_type(char *VariableName);
int lookup_position(char *VariableName);
void print_symbol_table(void);
ParType typeDefinition(ParType Arg1, ParType Arg2);
const char *  typePrefix(ParType Arg1);


/* Defining the Symbol table. A simple linked list. */
ST_TABLE symbolTable;
/* Let us start from value 1. */
int current_stack_value = 1;
/* Dirty code. This global is used to pass the variable declaration to lower levels...*/
ParType varCurrentType;

/* Adding a Variable entry to the symbol table. */
int addvar(char *VariableName,ParType TypeDecl)
{
	ST_ENTRY *newVar;
	if (!lookup(VariableName))
		{
		newVar = malloc(sizeof(ST_ENTRY));
		newVar->varname = VariableName;
		newVar->vartype = TypeDecl;
		newVar->position = current_stack_value;
		SGLIB_LIST_ADD(ST_ENTRY, symbolTable, newVar, next_st_var);
		current_stack_value++;
		return 1;
		}
	else return 0; /* error variable already in Table. */
}

/* Looking up a symbol in the symbol table. Returns 0 if symbol was not found. */
int lookup(char *VariableName){
	ST_ENTRY *var, *result;
	var = malloc(sizeof(ST_ENTRY));
	var->varname = strdup(VariableName);
	SGLIB_LIST_FIND_MEMBER(ST_ENTRY,symbolTable,var,ST_COMPARATOR,next_st_var, result);
	free(var);
   if (result == NULL) {return 0;}
   else {return 1;}
}

/* Looking up a symbol type in the symbol table. Returns 0 if symbol was not found. */

ParType lookup_type(char *VariableName)
{
	ST_ENTRY *var, *result;
	var = malloc(sizeof(ST_ENTRY));
	var->varname = strdup(VariableName);
	SGLIB_LIST_FIND_MEMBER(ST_ENTRY,symbolTable,var,ST_COMPARATOR,next_st_var, result);
	free(var);
   if (result == NULL) {return type_error;}
   else {return result->vartype;}
}

/* Looking up a poisition in the symbol table. Returns 0 if the variable was not found. */
int lookup_position(char *VariableName)
{
	ST_ENTRY *var, *result;
	var = malloc(sizeof(ST_ENTRY));
	var->varname = strdup(VariableName);
	SGLIB_LIST_FIND_MEMBER(ST_ENTRY,symbolTable,var,ST_COMPARATOR,next_st_var, result);
	free(var);
   if (result == NULL) {return 0;}
   else {return result->position;}
}

/* Printing the complete Symbol Table. You could use it for debugging. */
void print_symbol_table(void)
{
  ST_ENTRY *var;
  printf("\n Symbol Table Generated \n");
  SGLIB_LIST_MAP_ON_ELEMENTS(ST_ENTRY, symbolTable, var, next_st_var, {
    fprintf(stderr,"ST:: Name %s of type %d (%s) in Position %d \n", var->varname, var->vartype, ((var->vartype == type_integer) ? "i" : "f"), var->position);
    });
}

/* end of function declarations for variable management */

/* ********************************************************************************** */
/* Function Definitions for Syntax and Semantic Analysis */
/* Type inferece regarding arithmetic expressions. Typing
   with coersion.  */
ParType typeDefinition(ParType Arg1, ParType Arg2)
{
	if (Arg1 == type_integer && Arg2 == type_integer) {return type_integer;}
	if (Arg1 == type_integer && Arg2 == type_real) {return type_real;}
	if (Arg1 == type_real && Arg2 == type_integer) {return type_real;}
	if (Arg1 == type_real && Arg2 == type_real) {return type_real;}
	else {yyerror("Type missmatch");}
}


/* Function Definitions that output code. */

/* Prints the correct type for the JVM Commands */
const char *  typePrefix(ParType Arg1)
{
	static char * typePrefices[] = {"error", "i", "f", "b"};
	  return typePrefices[Arg1];
}



/* Function that prints preample code in class file.  */
void create_preample(char *className){
	fprintf(yyout,".class public %s \n",className);
	fprintf(yyout,".super java/lang/Object\n\n");
	fprintf(yyout,".method public static main([Ljava/lang/String;)V\n");
	/* this is an overkill but will do for educational purposes */
	fprintf(yyout," .limit locals 20 \n .limit stack 20\n");
}
