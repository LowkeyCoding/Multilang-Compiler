# Multilang-Compiler

Compiler written in Nim.
Compiles multiple languages to c.

## Supported languages:
Brainfuck  
Lisp(\*)  
Perl(\*)  
Python(\*)  
(\*) In the works
## Usage:
BFC ARGS
### ARGS:
-h, --help: prints usage guide.  
-i, --input: The input file.  
-o, --output: The output file.  
-C: Compiles to C (DEFAULT).  
--staticDepth: Use static tape size of "2000000000".  
--verbose: Enable verbose output.
