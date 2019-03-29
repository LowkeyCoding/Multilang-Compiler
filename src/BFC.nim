#Parameter Handling
import os
#Files manipulation
import ./libs/files/src/files.nim
#String manipulation
import ./libs/strutil/src/strutil.nim

proc generateCodeC(code: string):string = 
  var j = 0;
  var tapLevel = 1;
  var opCount  = 1;
  var currentDepth = 0;
  var maxDepth = 0;
  var whileFlag = true
  var code = code #removeUntil(code, "/*", "*\\");
  for op in code:
      case op:
        of '>':
          inc currentDepth
        of '<':
          dec currentDepth
        else:
          j = 0;
      if (currentDepth > maxDepth):
        maxDepth = currentDepth;
  
  var result = "#include <stdio.h>\nchar tape[" & $(maxDepth*10) & "];\nchar *ptr;\nint main() {\n  ptr=tape;\n"
  
  for i, op in code:
    if i == j:
      case code[i]:
        of '>':
          if code[i+1] == '>':
            while whileFlag:
              if code[i+opCount] == '>':
                inc opCount;
              else:
                whileFlag = false;
            j += opCount-1;
            result &= addString("  ", tapLevel) & "ptr+=" & $opCount & ";\n";
            opCount = 1;
            whileFlag = true;
          else:
            result &= addString("  ",tapLevel) & "ptr++;\n";
        of '<':
          if code[i+1] == '<':
            while whileFlag:
              if code[i+opCount] == '<':
                inc opCount;
              else:
                whileFlag = false;
            j += opCount-1;
            result &= addString("  ", tapLevel) & "ptr-=" & $opCount & ";\n";
            opCount = 1;
            whileFlag = true;
          else:
            result &= addString("  ",tapLevel) & "ptr--;\n";
        of '+':
          if code[i+1] == '+':
            while whileFlag:
              if code[i+opCount] == '+':
                inc opCount;
              else:
                whileFlag = false;
            result &= addString("  ", tapLevel) & "(*ptr)+=" & $opCount & ";\n";
            j += opCount-1;
            opCount = 1;
            whileFlag = true;
          else:
            result &= addString("  ",tapLevel) & "(*ptr)++;\n";
        of '-':
          if code[i+1] == '-':
            while whileFlag:
              if code[i+opCount] == '-':
                inc opCount;
              else:
                whileFlag = false;
            j += opCount-1;
            result &= addString("  ", tapLevel) & "(*ptr)-=" & $opCount & ";\n";
            opCount = 1;
            whileFlag = true;
          else:
            result &= addString("  ",tapLevel) & "(*ptr)--;\n";
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
          echo "invalid char: ", op; 
      inc j;
  return result & "return 1;\n}"
proc generateCode(code: string, lang: string = "C"):string =
  case lang:
    of "C":
      return generateCodeC(code)

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
  writeToFile(generateCode(readFromFile(inputFileName), lang),outputFileName)
