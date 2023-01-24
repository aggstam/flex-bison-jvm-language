# flex-bison-jvm-language

Simple Flex and Bison programs producing the corresponding C code to validate
provided SimpleLanguage (.sl) file syntax, perform semantic analysis and compile to
JVM asembly(jasmin), which can then be executed.
<br>
SimpleLanguage syntax:
```
start {program name}
{command0}
    .
    .
    .
{commandN}
end
```

Two types of commands exist:
1. Assignment(affix format): ({var} (expression))
2. Print: (print {var or (expression)})

Assigment command example:
```
(x (3 4 +))
```

Print command examples:
```
(print (3 4 +))
(print x)
```

Notes:
- Each command is enclosed in parentheses
- Type casting and coersion are supported
- Variables are not declared(type is deducted by first assignment)

Compilation and tests execution is streamline via a Makefile.
<br>
Six valid and one invalid test SimpleLanguage files have been provided to play with.

# Usage
```
% make
```
Makefile can be configured to use a different test case set and/or files.

# Execution example
```
❯ make test
flex -s -o json_lexer.c json_lexer.l
bison -v -o json_parser.c json_parser.y
gcc -Iexternal json_parser.c external/jsonValidatorSymbolTable.c -o json_validator -lfl
./json_validator test_files/widget.json
Total Syntax Errors found 0 
./json_validator test_files/widget_error.json
Entity:: "window" on line 8. ERROR in line 8: Entity already defined. Discarting..
Entity ("debug" : "on") Expected Type integer. ERROR in line 11: Type Missmatch!.
Entity ("height" : int) Expected Type real. ERROR in line 16: Type Missmatch!.
Entity "color" has not been declared. ERROR in line 17: Missing Declation!.
Total Syntax Errors found 0 
./json_validator test_files/widget_1.json
Total Syntax Errors found 0 
./json_validator test_files/widget_1_error.json
ERROR in line 10: syntax error, unexpected '{', expecting '}'.
ERROR in line 12: syntax error, unexpected T_string, expecting ':'.
Entity ("width" : real) Expected Type integer. ERROR in line 14: Type Missmatch!.
Lexical Analysis: Unexpected String! :: .  in line 14. 
Total Syntax Errors found 2 
./json_validator test_files/menu.json
Total Syntax Errors found 0 
./json_validator test_files/menu_error.json
Entity ("menuitem" : array) Expected Length 3, not 4. ERROR in line 17: Length Missmatch!.
Total Syntax Errors found 0 
```
