import std/[os, tables]
import jsony

type
  Scripts* = Table[string, string]
  Package = object of RootObj
    scripts: Scripts

proc walkUpPackages*(requireNodeModules= false): iterator(): tuple[packageJson: string, nodeModules: string] =
  return iterator(): tuple[packageJson: string, nodeModules: string] {.inline.} =
    var path = os.getCurrentDir()

    for dir in path.parentDirs():
      if dir != "/":
        let packageJson = dir & "/package.json"
        let nodeModules = dir & "/node_modules"

        if os.fileExists(packageJson) and (not requireNodeModules or os.dirExists(nodeModules)):
          yield (packageJson, nodeModules)

proc parseScriptsFromPackageJson*(jsonString: string): Scripts =
  let package = jsonString.fromJson(Package)
  result = package.scripts
