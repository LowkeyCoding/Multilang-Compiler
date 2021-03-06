type
    SkipTable = array[char,int]

proc initSkipTable(a: var SkipTable, sub: string) =
    ##[
      :LOCAL_FUNCTION: Initialize table used in find(string, substring)
    ]##
    let m = len(sub)
    var i = 0
    while i <= 0xff-7:
      a[chr(i + 0)] = m
      a[chr(i + 1)] = m
      a[chr(i + 2)] = m
      a[chr(i + 3)] = m
      a[chr(i + 4)] = m
      a[chr(i + 5)] = m
      a[chr(i + 6)] = m
      a[chr(i + 7)] = m
      i += 8
    for i in 0 ..< m - 1:
      a[sub[i]] = m - 1 - i
proc stringFind(skibTable: SkipTable,str,sub: string,start: Natural = 0,last = 0): int =
  let
    last = if last==0: str.high else: last
    sLen = last - start + 1
    subLast = sub.len - 1

  if subLast == -1:
    return start
  var skip = start

  while last - skip >= subLast:
    var i = subLast
    while str[skip + i] == sub[i]:
      if i == 0:
        return skip
      dec i
    inc skip, skibTable[str[skip + subLast]]

  return -1
proc find*(str: string, sub: string): int =
  ##[
    :USAGE: find(string, substring)
    :BEHAVIOR: Finds substring in string and returns start position of the string.
    :BEHAVIOR: If substring is not found it will return -1.
    :IMPLEMENTAION OF: https://en.wikipedia.org/wiki/Boyer%E2%80%93Moore%E2%80%93Horspool_algorithm
  ]##
  var skipTable {.noinit.}: SkipTable
  initSkipTable(skipTable, sub)
  return stringFind(skipTable, str, sub)
proc match*(str: string, sub: string): bool =
  ##[
    :USAGE: match(string, substring)
    :BEHAVIOR: Checks if substring exists in string
  ]##
  var skipTable {.noinit.}: SkipTable
  initSkipTable(skipTable, sub)
  if stringFind(skipTable, str, sub) != -1:
    return true
proc remove*(str: string, sub: string): string =
  ##[
    :USAGE: remove(string, substring)
    :BEHAVIOR: Removes all instances of substring in string.
  ]##
  var str = str
  var check = find(str, sub)
  while true:
    str = substr(str, 0, find(str, sub)-1) & substr(str, find(str, sub)+len(sub), len(str))
    check = find(str, sub)
    if check == -1:
      return str
proc removeUntil*(str: string, SOS: string, EOS: string): string =
  ##[
    :USAGE: removeUntil(string, startOfString, EndOfString)
    :BEHAVIOR: Removes chars between startOfString and EndOfString.
  ]##

  var str = str
  var strStart = find(str, SOS)
  var strEnd = find(str, EOS)
  while true:
    if strStart == -1:
      return str
    str = remove(str, substr(str, strStart, strEnd))
    strStart = find(str, SOS)
    strEnd = find(str, EOS)
    echo strStart
    echo strEnd
    if strEnd == -1:
      strEnd = len(str)
proc strip*(str: string): string =
  ##[
    :USAGE: strip(string)
    :BEHAVIOR: Removes whitespace chars.
  ]##
  let whitespaces = [" ", "\t", "\v", "\r", "\l", "\f"]
  var str = str
  for whitespace in whitespaces:
    str = remove(str, whitespace)
  return str
proc addString*(chr: string, times: int = 1):string =
  ##[
    :USAGE: addString(char or string, times)
    :BEHAVIOR: generates a string with the (char/string) repeated x times.
    :USAGE IN CODE: for creating readable files with appropriate amount of tabs/spaces
  ]##
  var result = ""
  for i in 1..times:
    result &= chr
  return result