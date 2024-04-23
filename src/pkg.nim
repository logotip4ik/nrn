import std/[os, sequtils, strformat, tables, json]

type
  Scripts* = Table[string, string]

proc findFile*(filename: string, findOne = true): seq[string] =
  var path = os.getCurrentDir()

  for dir in path.parentDirs().toSeq():
    let filePath = fmt"{dir}/{filename}"

    if os.fileExists(filePath):
      result.add(filePath)

      if findOne: break

proc findFolder*(folder: string, findOne = true): seq[string] =
  var path = os.getCurrentDir()

  for dir in path.parentDirs().toSeq()[0..2]:
    let dirPath = fmt"{dir}/{folder}"

    if os.dirExists(dirPath):
      result.add(dirPath)

      if findOne: break

proc parseScriptsFromPackageJson*(jsonString: string): Scripts =
  let packageJson = json.parseJson(jsonString)
  result = json.to(packageJson["scripts"], Scripts)
