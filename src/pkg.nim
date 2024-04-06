import std/[os, sequtils, strformat, tables, json, options]

const PackgeJsonFilename = "package.json"

type
  Scripts* = Table[string, string]
  PackageJson* = object
    scripts*: Table[string, string]

proc findFile*(filename: string): Option[string] =
  var path = os.getCurrentDir()

  for dir in path.parentDirs().toSeq()[0..2]:
    let filePath = fmt"{dir}/{PackgeJsonFilename}"

    if os.fileExists(filePath):
      return some(filePath)

  return none(string)

proc findFolder*(folder: string): Option[string] =
  var path = os.getCurrentDir()

  for dir in path.parentDirs().toSeq()[0..2]:
    let dirPath = fmt"{dir}/{folder}"

    if os.dirExists(dirPath):
      return some(dirPath)

  return none(string)

proc parseScriptsFromPackageJson*(jsonString: string): Scripts =
  let packageJson = json.parseJson(jsonString)
  result = json.to(packageJson["scripts"], Scripts)
