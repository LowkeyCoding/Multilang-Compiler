#Dette er en lexical analyzer til sproget perl.

#These are the libraries and modules we have imported.
import ./libs/strutil/src/strutil.nim
import os

#Start of lexical analysis
echo "Initiating compiler"
echo "Starting lexical analysis"

#Here we assign token values to the symbols. This will be important later when we're
#tokenizing the input code.
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

#Here we assign token values to the rest.
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
		notq = "notEqualTo",
		less = "lessThan",
		lesq = "lessOrEqual",
		equa = "equalTo",
		greq = "greaterOrEqual",
		grea = "greaterThan",
		notq = "notEqual",
		tkif = "if",
		tkel = "else",
		tkwh = "while",
		prin = "print",
		tkid = "identifier",
		inte = "integer",
		tkch = "character",
		stri = "string"
		endo = "endOfInput"


token = object
	kind: tokenKind
	value: string

#This is where we start working with the input.
#This function strips the code from junk, AKA, unimportant information like spaces.
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

#This function, as it's name suggets, tokenizes the input code.
#
proc tokenize*(text: string): seq[tokenAnn]=
	result = newSeq[tokenAnn]()
	var
		lineNo, colNo: int = 1
		text=text
		token: Token
		tokenLength: int

	while text.len > 0:
		strip(text, lineNo, colNo)
		token=consumeToken(text, tokenLength)
		result.add TokenAnn(token: token, line: lineNo, column: colNo)
		inc colNo, tokenLength

#This is where the 
proc output*(s: seq[TokenAnn]): string=
	var
		tokenKind: tokenKind
		value: string
		line, column: int

	for tokenAnn in items(s):
		line=tokenAnn.line
		column=tokenAnn.column
		tokenKind=tokenAnn.token.kind
		value=tokenAnn.token.value
		result.add(
			fmt"{line:>5}{column:>7}{tokenKind:<15}{value}"
				.strip(leading=false) & "\n")
	)

when isMainModule:
	import os

	let input=if paramCount() > 0: readFile paramStr(1)
else: readAll stdin

#At last we output the tokenized output.
echo input.tokenize.output