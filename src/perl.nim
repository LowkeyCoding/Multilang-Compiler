#Dette er en lexical analyzer til sproget perl.

#These are the libraries and modules we have imported.
import ./libs/strutil/src/strutil.nim
import os

#Start of lexical analysis
echo "Initiating compiler"
echo "Starting lexical analysis"

const
    tksymbols = {
    	'%': modi,
    	'+': add,
    	'-': subt,
    	'/': divi,
    	'*': mult,
	';': semi,
	',': comm,
	'{': rbra,
	'}': lbra,
	'(': rpar,
	')': lpar,
	}
symbols = getSymbols(tksymbols)

proc 

type
    tKind = enum
    	unow = "TOKEN_UNKNOWN",
    	mult = "multiply",
    	divi = "divide",
    	modi = "modify",
    	subt = "subtract",
    	semi = "semicolon",
    	comm = "comma",
    	rbra = "rightBracket",
    	lbra = "leftBracket",
    	rpar = "rightParanthesis",
    	lpar = "leftParanthesis",



token = object
	kind: tokenKind
	value: string
