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

## Usage
```
% make
```
Makefile can be configured to use a different test case set and/or files.

## Execution example
```
❯ make test
flex -s -o lexer.c lexer.l
bison -v -o parser.c parser.y
gcc -Iexternal parser.c -o compiler -lfl
Errors found 0.
Generated: test_0.class
7
Errors found 0.
Generated: test_1.class
49
49.0
Errors found 0.
Generated: test_2.class
7.0
11.0
Errors found 0.
Generated: test_3.class
7.0
Errors found 0.
Generated: test_4.class
7
Errors found 0.
Generated: test_5.class
7
Errors found 0.
Generated: test_6.class
7.0
3
ERROR: syntax error, unexpected ')'. on line 2.
Warning: value is already int, in line 4.
Variable z NOT initialized, in line 5. ERROR: Variable fault. on line 5.
Integer var y. ERROR: Narrowing Conversion (float to int). on line 6.
Warning: value is already real, in line 8.
Variable x NOT initialized, in line 9. ERROR: Variable fault. on line 9.
Errors found 4.
No Code Generated.
make: [Makefile:40: test] Error 1 (ignored)
```
