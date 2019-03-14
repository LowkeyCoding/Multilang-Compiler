#String manipulation
import os
import ./libs/strutil/src/strutil.nim

proc generateCodeC(code: string):string = 
  var result = "#include <stdio.h>\nchar tape[2147483647/2];\nchar *ptr;\nint main() {\n  ptr=tape;\n"
  var tapLevel = 1;
  var code = removeUntil(code, "//", "\n")
  code = strip(code)
  for word in code:
    case word:
      of '>':
        result &= addString("  ",tapLevel) & "ptr++;\n"
      of '<':
        result &= addString("  ",tapLevel) & "ptr--;\n"
      of '+':
        result &= addString("  ",tapLevel) & "(*ptr)++;\n"
      of '-':
        result &= addString("  ",tapLevel) & "(*ptr)--;\n"
      of '.':
        result &= addString("  ",tapLevel) & "putchar(*ptr);\n"
      of ',':
        result &= addString("  ",tapLevel) & "*ptr=getchar();\n"
      of '[':
        result &= addString("  ",tapLevel) & "while (*ptr){\n"
        inc tapLevel
      of ']':
        result &= addString("  ",tapLevel) & "}\n"
        dec tapLevel
      else:
        return word & " ERROR"
  return result & "return 1;\n}"

proc generateCode(code: string, lang: string = "C"):string =
  case lang:
    of "C":
      return generateCodeC(code)

proc writeToFile(code: string, fileName: string) =
  var file = open(fileName, fmWrite)
  file.write(code)

proc readFile(fileName: string):string =
  var result = ""
  var file = open(fileName)
  for line in file.lines:
    result &= line
  return result

when isMainModule:
  var inputFileName = ""
  var outputFileName = ""
  var lang = "C"
  for i in 1..paramCount():
    case paramStr(i):
      of "--input":
        inputFileName = paramStr(i+1)
      of "-i":
        inputFileName = paramStr(i+1)
      of "--output":
        outputFileName = paramStr(i+1)
      of "-o":
        outputFileName = paramStr(i+1)
      of "--lang":
        lang = paramStr(i+1)
      of "-l":
        lang = paramStr(i+1)
  writeToFile(generateCode(readFile(inputFileName), lang),outputFileName)