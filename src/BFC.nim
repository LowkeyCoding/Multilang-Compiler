#Parameter Handling
import os
#Files manipulation
import /libs/files/src/files
#String manipulation
import /libs/strutil/src/strutil

proc evalCodeLoop(code: string, index: int, oldLoop, newMaxDepth, newIndex: var int, verbose: bool) = 
  var maxDepth = newMaxDepth;
  var currentDepth = 0;
  var index = index;
  var loop = 0;
  while true:
    if code[index] == '[':
      echo "Loops: " & $oldLoop
      evalCodeLoop(code, index+1, loop, maxDepth, index, verbose)
    elif code[index] == '+':
        inc loop
    elif code[index] == '>':
      inc currentDepth;
      if currentDepth > maxDepth:
        if verbose:
          echo "Max depth: " & $maxDepth;
        maxDepth = currentDepth;
    elif code[index] == '<':
      dec currentDepth;
    elif (code[index] == ']') == (oldLoop < 0):
      newMaxDepth = maxDepth;
      newIndex = index;
      return
    else:
      loop = 0;
      inc index
      continue;
    dec oldLoop
    inc index

proc evalCode(code: string, verbose: bool): int = 
  var maxDepth = 0;
  var currentDepth = 0;
  var index = 0;
  var loop = 0;
  for i, op in code:
    if i == index:
      case code[i]:
        of '>':
          inc currentDepth;
          if currentDepth > maxDepth:
            if verbose:
              echo "Max depth: " & $maxDepth;
            maxDepth = currentDepth;
        of '<':
          dec currentDepth;
        of '+':
          inc loop;
        of '[':
          if verbose:
            echo "Loops: " & $loop;
          evalCodeLoop(code, i+1, loop, maxDepth, index, verbose);
        else: 
          loop = 0;
      inc index;
  return maxDepth
  
proc generateCodeC(code: string, increasedSize: bool, verbose: bool): string = 
  var j = 0;
  var tapLevel = 1;
  var opCount  = 1;
  var whileFlag = true;
  var code = code; #removeUntil(code, "/*", "*\\");
  var result = "";
  if increasedSize:
    result = "#include <stdio.h>\nchar tape[" & $(2000000000) & "];\nchar *ptr;\nint main() {\n  ptr=tape;\n";
  else:
    var maxDepth = evalCode(code, verbose)
    result = "#include <stdio.h>\nchar tape[" & $maxDepth & "];\nchar *ptr;\nint main() {\n  ptr=tape;\n";

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
          if verbose:
            echo "invalid char: ", op; 
      inc j;
  return result & "return 1;\n}";

proc generateCode(code: string, lang: string = "C", increasedSize: bool, verbose: bool):string =
  case lang:
    of "C":
      return generateCodeC(code, increasedSize, verbose)

when isMainModule:
  var inputFileName = "";
  var outputFileName = "";
  var increasedSize = false;
  var verbose = false;
  var lang = "C"
  for i in 1..paramCount():
    case paramStr(i):
      of "--input":
        inputFileName = paramStr(i+1);
      of "-i":
        inputFileName = paramStr(i+1);
      of "--output":
        outputFileName = paramStr(i+1);
      of "-o":
        outputFileName = paramStr(i+1);
      of "--lang":
        lang = paramStr(i+1);
      of "-l":
        lang = paramStr(i+1);
      of "--size":
        increasedSize = true
      of "-s":
        increasedSize = true
      of "--verbose":
        verbose = true
  writeToFile(generateCode(readFromFile(inputFileName), lang, increasedSize, verbose),outputFileName)
