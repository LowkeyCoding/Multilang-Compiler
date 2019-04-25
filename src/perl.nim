#Dette er en lexical analyzer til sproget perl.

#These are the libraries and modules we have imported.
#import ./libs/strutil/src/strutil.nim
#import os
#import strutils
#import strformat
import re, strformat, strutils

#Start of lexical analysis
echo "Initiating compiler"
echo "Starting lexical analysis"

#Here we assign token values to the rest.
type
  TokenKind = enum
    unow = "TOKEN_UNKNOWN",
    mult = "multiply",
    divi = "divide",
    modi = "modify",
    subt = "subtract",
    tkad = "add"
    semi = "semicolon",
    comm = "comma",
    rbra = "rightBracket",
    lbra = "leftBracket",
    rpar = "rightParanthesis",
    lpar = "leftParanthesis",
    less = "lessThan",
    lesq = "lessOrEqual",
    equa = "equalTo",
    asig = "Assign",
    greq = "greaterOrEqual",
    grea = "greaterThan",
    tkno = "not",
    notq = "notEqual",
    tkor = "or",
    tkan = "and",
    tkif = "if",
    tkel = "else",
    tkwh = "while",
    prin = "print",
    tkpu = "put",
    tkid = "identifier",
    inte = "integer",
    tkch = "character",
    stri = "string",
    endo = "endOfInput"


#Here we assign token values to the symbols. This will be important later when we're
#tokenizing the input code.
const
  tksymbols = {
    '%': modi,
    '+': tkad,
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


type Token = object
  kind: TokenKind
  value: string

type TokenAnn = object
  line: int
  column: int
  token: Token

proc getSymbols(table: openArray[(char, TokenKind)]): seq[char] =
  result = newSeq[char]()
  for ch, tokenKind in items(table):
    result.add ch

const symbols = getSymbols(tksymbols)

proc findTokenKind(table: openArray[(char, TokenKind)]; needle: char): TokenKind =
  for ch, tokenKind in items(table):
    if ch == needle: return tokenKind
  unow

proc stripComment(text: var string, lineNo, colNo: var int) =
  var matches: array[1, string]
  if match(text, re"\A(/\*[\s\S]*?\*/)", matches):
    text = text[matches[0].len..^1]
    for s in matches[0]:
      if s == '\n':
        inc lineNo
        colNo = 1
      else:
        inc colNo

#This is where we start working with the input.
#This function strips the code from junk, AKA, unimportant information like spaces.
proc strip(text: var string; lineNo, colNo: var int) =
  while true:
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

proc lookAhead(ch1, ch2: char, tk1, tk2: TokenKind): (TokenKind, int) =
  if ch1 == ch2: (tk1, 2)
  else: (tk2, 1)

proc conToken(text: var string; tkl: var int): Token =
  var
    matches: array[1, string]
    tokenKind: TokenKind
    val: string

  if text.len == 0:
    (tokenKind, tkl) = (endo, 0)

  elif text[0] in symbols: (tokenKind, tkl) = (tkSymbols.findTokenKind(text[0]), 1)
  elif text[0] == '<': (tokenKind, tkl) = lookAhead(text[1], '=', less, lesq)
  elif text[0] == '>': (tokenKind, tkl) = lookAhead(text[1], '=', grea, greq)
  elif text[0] == '=': (tokenKind, tkl) = lookAhead(text[1], '=', equa, asig)
  elif text[0] == '!': (tokenKind, tkl) = lookAhead(text[1], '=', notq, tkno)
  elif text[0] == '&': (tokenKind, tkl) = lookAhead(text[1], '&', tkan, unow)
  elif text[0] == '|': (tokenKind, tkl) = lookAhead(text[1], '|', tkor, unow)

  elif match(text, re"\Aif\b"): (tokenKind, tkl) = (tkif, 2)
  elif match(text, re"\Aelse\b"): (tokenKind, tkl) = (tkel, 4)
  elif match(text, re"\Awhile\b"): (tokenKind, tkl) = (tkwh, 5)
  elif match(text, re"\Aprint\b"): (tokenKind, tkl) = (prin, 5)
  elif match(text, re"\Aputc\b"): (tokenKind, tkl) = (tkpu, 4)

  elif match(text, re"\A([0-9]+)", matches):
    (tokenKind, tkl) = (inte, matches[0].len)
    val = matches[0]
  elif match(text, re"\A([_a-zA-Z][_a-zA-Z0-9]*)", matches):
    (tokenKind, tkl) = (tkId, matches[0].len)
    val = matches[0]
  elif match(text, re"\A('(?:[^'\n]|\\\\|\\n)')", matches):
    (tokenKind, tkl) = (tkch, matches[0].len)
    val = case matches[0]
          of r"' '": $ord(' ')
          of r"'\n'": $ord('\n')
          of r"'\\'": $ord('\\')
          else: $ord(matches[0][1]) # "'a'"[1] == 'a'
  elif match(text, re"\A(""[^""\n]*"")", matches):
    (tokenKind, tkl) = (stri, matches[0].len)
    val = matches[0]
  else: (tokenKind, tkl) = (unow, 1)
 
  text = text[tkl..^1]
  Token(kind: tokenKind, value: val)
#This function, as it's name suggets, tokenizes the input code.
#
proc tokenize*(text: string): seq[TokenAnn]=
  result = newSeq[  TokenAnn]()
  var
    lineNo, colNo: int = 1
    text=text
    token: Token
    tokenLength: int

  while text.len > 0:
    strip(text, lineNo, colNo)
    token=conToken(text, tokenLength)
    result.add TokenAnn(token: token, line: lineNo, column: colNo)
    inc colNo, tokenLength

#This is where the 
proc output*(s: seq[TokenAnn]): string=
  var
    tokenKind: tokenKind
    value: string
    line, column: int

  for TokenAnn in items(s):
    line=TokenAnn.line
    column=TokenAnn.column
    tokenKind=TokenAnn.token.kind
    value=TokenAnn.token.value
    result.add(
      fmt"{line:>5}{column:>7}{tokenKind:<15}{value}"
        .strip(leading=false) & "\n"))

when isMainModule:
  import os
  let input=if paramCount() > 0: readFile paramStr(1)
      else: readAll stdin

#At last we output the tokenized output.
echo input.tokenize.output