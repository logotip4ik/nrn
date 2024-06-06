import std/[os, sequtils, strformat, tables]
import jsony

type
  Scripts* = Table[string, string]
  Package = object
    scripts: Scripts

proc walkUpPackages*(checkNodeModules = false): iterator(): tuple[packageJson: string, nodeModules: string] =
  return iterator(): tuple[packageJson: string, nodeModules: string] {.inline.} =
    var path = os.getCurrentDir()

    for dir in path.parentDirs().toSeq():
      let packageJson = fmt"{dir}/package.json"
      let nodeModules = if not checkNodeModules: "" else: fmt"{dir}/node_modules"

      if dir == "/":
        return

      if os.fileExists(packageJson) and (not checkNodeModules or os.dirExists(nodeModules)):
        yield (packageJson, nodeModules)

proc parseScriptsFromPackageJson*(jsonString: string): Scripts =
  let package = jsonString.fromJson(Package)
  result = package.scripts
