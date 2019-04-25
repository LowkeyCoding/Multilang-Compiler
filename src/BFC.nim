#Parameter Handling
import os
#Files manipulation
import /libs/files/src/files
#String manipulation
import /libs/strutil/src/strutil

#-----Depthscan-----#
proc depthScanLoop*(code: string, startIndex: int, oldLoop, maxDepth, newIndex, currentDepth: var int, verbose: bool) = 
  ##[
      :USAGE: depthScanLoop(code: string, startIndex: int, oldLoop, maxDepth, newIndex, currentDepth: var int, verbose: bool)
      :BEHAVIOR:  Goes through each operand in the code, to determin the amount of cells needed to run the code.
      :code: The code to scan through.
      :startIndex: The starting point in the code.
      :oldLoop: The number times the code in the loop needs to be run.
      :maxDepth: Used to update the state of the top level maxDepth.
      :newIndex: Used to update the state of the top level trueIndex.
      :currentDepth: Used to update the state of the top level currentDepth.
      :verbose: Toggles console output.
  ]##
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
        if verbose:
          echo "exit loop"
        break;
      else:
        loop = 0;
        inc index
        continue;
      inc index
    dec oldLoop
    if oldLoop == 0:
      newIndex = index;
      return

proc depthScan*(code: string, verbose: bool): int = 
  ##[
      :USAGE: depthScan(code: string, verbose: bool)
      :BEHAVIOR: The top level function for keeping track of depthScan
      :code: The code to scan through.
      :verbose: Toggles console output.
  ]##
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

#-----Code optimization-----#
proc operandCombiner*(code: string, index, tapLevel: var int, result: var string, operand: char, operandCode: string, operandCodeMulti: string, verbose: bool) =
  ##[
      :USAGE: operandCombiner(code: string, currentIndex: int, trueIndex, tapLevel: var int, result: var string, operand: char, operandCode: string, operandCodeMulti: string)
      :BEHAVIOR: Combines operands of the same type, and adds the the combined operands to result.
      :code: The code to scan through.
      :index: Used to keep track of the current location in the code.
      :tapLevels: Used to keep track of indetation.
      :result: Used to store the generated code.
      :operand: The operand to combine.
      :operandCode: The operands equivalent code when only a single operand is present.
      :operandCodeMulti: The operands equivalent code when multiple operands are present.
  ]##
  var whileFlag = true;
  var opCount = 1;
  if(code[index+1] == operand):
    while whileFlag:
      if code[index+opCount] == operand:
        inc opCount;
      else:
        if verbose:
          echo "Combined: " & operand & " " & $opCount & " times"
        whileFlag = false;
        index += opCount-1;
    result &= addString("  ", tapLevel) & operandCodeMulti & $opCount & ";\n";
  else:
    result &= addString("  ",tapLevel) & operandCode;

#-----Code genration-----#
proc generateCodeC*(code: string, staticDepth: bool, verbose: bool): string = 
  ##[
      :USAGE: generateCodeC(code: string, staticDepth: bool, verbose: bool)
      :BEHAVIOR: Used to go through each operand of brainfuck and generate C code 
      :code: The code to convert to C.
      :staticDepth: Toggles static vs dynamic depth. Static is close to 32bit limit to give support for more systems.
      :verbose: Toggles console output.
  ]##
  var index = 0;
  var tapLevel = 1;
  var result = "";
  if staticDepth:
    result = "#include <stdio.h>\nchar tape[" & $(2000000000) & "];\nchar *ptr;\nint main() {\n  ptr=tape;\n";
  else:
    var maxDepth = depthScan(code, verbose)
    result = "#include <stdio.h>\nchar tape[" & $maxDepth & "];\nchar *ptr;\nint main() {\n  ptr=tape;\n";
  if verbose:
    echo "Code Generation started"
  while index != len(code):
    case code[index]:
      of '>':
        operandCombiner(code, index, tapLevel, result, '>', "ptr++;\n", "ptr+=", verbose)
      of '<':
        operandCombiner(code, index, tapLevel, result, '<', "ptr--;\n", "ptr-=", verbose)
      of '+':
        operandCombiner(code, index, tapLevel, result, '+', "(*ptr)++;\n", "(*ptr)+=", verbose)
      of '-':
        operandCombiner(code, index, tapLevel, result, '-', "(*ptr)--;\n", "(*ptr)-=", verbose)
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
          echo "invalid char: ", code[index];
    inc index;
  return result & "return 1;\n}";

#-----Functioncallers-----#
proc generateCode*(code: string, lang: string = "C", staticDepth: bool, verbose: bool):string =
  ##[
      :USAGE: generateCode(code: string, lang: string, staticDepth: bool, verbose: bool)
      :BEHAVIOR: Used to select the output language.
      :code: The code to convert to x language.
      :lang: The desired language. DEFAULT: C.
      :staticDepth: Toggles static vs dynamic depth. Static is close to 32bit limit to give support for more systems.
      :verbose: Toggles console output.
  ]##
  case lang:
    of "C":
      if verbose:
          echo "Selected language: C"
      return generateCodeC(code, staticDepth, verbose)

#-----Userinput handler-----#
proc help*() =
  ##[
      :USAGE: help()
      :BEHAVIOR: Prints usage guide to console.
  ]##
  echo """
    -h --help: prints out help
    -i, --input: The input file.
    -o, --output: The output file.
    -C: Compiles to C (DEFAULT).
    --staticDepth: Use static tape size of \"2000000000\".
    --verbose: Enable verbose output. 
  """

proc userInput*()=
  ##[
      :USAGE: userInput()
      :BEHAVIOR: Takes user input and parses it.
  ]##
  var inputFileName = "";
  var outputFileName = "";
  var staticDepth = false;
  var verbose = false;
  var lang = "C";
  var unkownParameter = false;
  for i in 1..paramCount():
    case paramStr(i):
      of "--help":
        help()
        unkownParameter = true;
      of "-h":
        help();
        unkownParameter = true;
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
      else:
        if i > 4 and match(paramStr(i),"-"):
          echo "Unkown parameter: " & paramStr(i)
          help();
          unkownParameter = true;
  if unkownParameter != true:
    writeToFile(generateCode(readFromFile(inputFileName), lang, staticDepth, verbose),outputFileName)

when isMainModule:
  userInput()