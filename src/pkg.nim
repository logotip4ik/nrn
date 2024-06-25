import std/[os, strformat, tables]
import jsony

type
  Scripts* = Table[string, string]
  Package = object
    scripts: Scripts

proc findClosestPackageJson*(dir: string = os.getCurrentDir()): tuple[packageJson: string, nodeModules: string] =
  if dir == "/":
    return

  for path in dir.parentDirs():
    let packageJson = fmt"{dir}/package.json"

    if os.fileExists(packageJson):
      return (packageJson, fmt"{dir}/node_modules")

iterator walkUpPackages*(): tuple[packageJson: string, nodeModules: string] =
  var path = os.getCurrentDir()

  for dir in path.parentDirs():
    let packages = findClosestPackageJson(dir)

    if packages.packageJson.len > 0:
      yield packages

proc parseScriptsFromPackageJson*(jsonString: string): Scripts =
  let package = jsonString.fromJson(Package)
  result = package.scripts
