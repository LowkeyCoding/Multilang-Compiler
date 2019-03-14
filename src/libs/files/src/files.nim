proc writeToFile*(code: string, fileName: string) =
    var file = open(fileName, fmWrite)
    file.write(code)
  
proc readFromFile*(fileName: string):string =
    var result = ""
    var file = open(fileName)
    for line in file.lines:
        result &= line
    return result
