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

proc strip(text: var string; lineNo, colNo: var ini) =
    while true
    	if text.len == 0: return
    	elif text[0] == '\n':
        	inc lineNo
        	colNo = 1
        	text = text[1..^1]
        elif text[0] == ' ':
           	 inc colNo
            	text = text[1..^1]
        elif text.len >= 2 and text[0] == '/' and text[1] == '*':
            stripComment(text, lineNo, colNo)
        else: return

proc lookAhead(ch1, ch2: char, tk1, tk2, tokenKind): (tokenKind, int) =
    if ch1 == ch2: (tk1, 2)
    else: (tk2, 1)

proc conToken(text: var string; tkl: var init): token =

    var
        matches: array[1, string]
        tKind: tokenKind
        val: string

    if text.len == 0;
    	(tkind, tkl) = ()

    elif text[0] in symbols: (tkind, tkl) = (
