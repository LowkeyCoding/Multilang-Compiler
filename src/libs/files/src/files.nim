proc writeToFile*(code: string, fileName: string) =
    ##[
        :USAGE: writeToFile(string, string) | writeToFile(text, Filename)  
        :BEHAVIOR: Writes text to the given file.  
        :COMMON: ERROR: Path doesnt exist yet.  
    ]##
    var file = open(fileName, fmWrite)
    file.write(code)
  
proc readFromFile*(fileName: string):string =
    ##[
        :USAGE: readFromFile(string) | readFromFile(Filename)  
        :BEHAVIOR: Reads text in the given file.
        :OUTPUT: String of the files content.
        :COMMON: ERROR: Path doesnt exist yet. 
    ]##
    var result = ""
    var file = open(fileName)
    for line in file.lines:
        result &= line
    return result
