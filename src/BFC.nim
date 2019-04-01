#Parameter Handling
import os
#Files manipulation
import /libs/files/src/files
#String manipulation
import /libs/strutil/src/strutil

#-----Depthscan-----#
proc depthScanLoop(code: string, startIndex: int, oldLoop, newMaxDepth, newIndex, currentDepth: var int, verbose: bool) = 
  var maxDepth = newMaxDepth;
  var index = startIndex;
  var loop = 0;
  for i in 1..oldLoop:
    while true:
      if code[index] == '[':
        if verbose:
          echo "Loops: " & $oldLoop
        depthScanLoop(code, index+1, loop, maxDepth, index, currentDepth, verbose)
        if currentDepth > maxDepth:
          if verbose:
            echo "Max depth: " & $maxDepth;
          maxDepth = currentDepth;
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
      elif code[index] == ']':
        break;
      else:
        loop = 0;
        inc index
        continue;
      inc index
    dec oldLoop
    if oldLoop == 0:
      newMaxDepth = maxDepth;
      newIndex = index;
      return

proc depthScan(code: string, verbose: bool): int = 
  var maxDepth = 0;
  var currentDepth = 1;
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
          depthScanLoop(code, i+1, loop, maxDepth, index, currentDepth, verbose);
        else: 
          loop = 0;
      inc index;
  return maxDepth

#-----Code genration-----#
proc oprandCombiner(code: string, currentIndex: int, trueIndex, tapLevel: var int, result: var string, oprand: char, oprandCode: string, oprandCodeMulti: string) =
  var whileFlag = true;
  var opCount = 1;
  if(code[currentIndex+1] == oprand):
    while whileFlag:
      if code[currentIndex+opCount] == oprand:
        inc opCount;
      else:
        whileFlag = false;
    trueIndex += opCount-1;
    result &= addString("  ", tapLevel) & oprandCodeMulti & $opCount & ";\n";
  else:
    result &= addString("  ",tapLevel) & oprandCode;

proc generateCodeC(code: string, staticDepth: bool, verbose: bool): string = 
  var index = 0;
  var tapLevel = 1;
  var code = code;
  var result = "";
  if staticDepth:
    result = "#include <stdio.h>\nchar tape[" & $(2000000000) & "];\nchar *ptr;\nint main() {\n  ptr=tape;\n";
  else:
    var maxDepth = depthScan(code, verbose)
    result = "#include <stdio.h>\nchar tape[" & $maxDepth & "];\nchar *ptr;\nint main() {\n  ptr=tape;\n";

  for i, op in code:
    if i == index:
      case code[i]:
        of '>':
          oprandCombiner(code, i, index, tapLevel, result, '>', "ptr++;\n", "ptr+=")
        of '<':
          oprandCombiner(code, i, index, tapLevel, result, '<', "ptr--;\n", "ptr-=")
        of '+':
          oprandCombiner(code, i, index, tapLevel, result, '+', "(*ptr)++;\n", "(*ptr)+=")
        of '-':
          oprandCombiner(code, i, index, tapLevel, result, '-', "(*ptr)--;\n", "(*ptr)-=")
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
      inc index;
  return result & "return 1;\n}";

#-----Functioncallers-----#
proc generateCode(code: string, lang: string = "C", staticDepth: bool, verbose: bool):string =
  case lang:
    of "C":
      return generateCodeC(code, staticDepth, verbose)

when isMainModule:
  var inputFileName = "";
  var outputFileName = "";
  var staticDepth = false;
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
      of "--staticDepth":
        staticDepth = true
      of "--verbose":
        verbose = true
  writeToFile(generateCode(readFromFile(inputFileName), lang, staticDepth, verbose),outputFileName)