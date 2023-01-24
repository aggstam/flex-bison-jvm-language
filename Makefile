FLEX_INPUT = lexer.l
FLEX_OUTPUT = lexer.c
BISON_INPUT = parser.y
BISON_OUTPUT = parser.c
GCC_OUTPUT = compiler
PARSER_OUTPUT = parser.output
EXTERNAL_FOLDER = external
HEADER_FILE = jvmSimp.h
TESTS_FOLDER = test_files
JASMIN = $(EXTERNAL_FOLDER)/jasmin.jar
TEST = EMPTY

define run-test =
	./$(GCC_OUTPUT) $(TESTS_FOLDER)/$(TEST).sl $(TEST).j && java -jar $(JASMIN) $(TEST).j && java $(TEST)
endef

all: compile	

compile:
	flex -s -o $(FLEX_OUTPUT) $(FLEX_INPUT)
	bison -v -o $(BISON_OUTPUT) $(BISON_INPUT)
	gcc -I$(EXTERNAL_FOLDER) $(BISON_OUTPUT) -o $(GCC_OUTPUT) -lfl

test: compile
	$(eval TEST=test_0)
	@$(run-test)
	$(eval TEST=test_1)
	@$(run-test)
	$(eval TEST=test_2)
	@$(run-test)
	$(eval TEST=test_3)
	@$(run-test)
	$(eval TEST=test_4)
	@$(run-test)
	$(eval TEST=test_5)
	@$(run-test)
	$(eval TEST=test_6)
	@$(run-test)
	$(eval TEST=test_error)
	-@$(run-test)

clean:
	rm -f $(FLEX_OUTPUT) $(BISON_OUTPUT) $(GCC_OUTPUT) $(PARSER_OUTPUT) *.j *.class
