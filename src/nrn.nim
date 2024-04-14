import system
import std/[options, strformat]

import args
import pkg
import run

when isMainModule:
  let nrnOptions = args.getOptions()

  if nrnOptions.pmCommand == PmCommand.Help:
    run.printHelp()
    system.quit()

  let packageJsonPath = pkg.findFile("package.json")
  let nodeModulesPath = pkg.findFolder("node_modules")

  if packageJsonPath.isNone:
    echo "no package.json found in tree"
    system.quit()

  if nodeModulesPath.isNone:
    echo "no node_modules found in tree"
    system.quit()

  let packageJsonString = readFile(packageJsonPath.get())
  let scripts = pkg.parseScriptsFromPackageJson(packageJsonString)

  run.run(
    nrnOptions,
    scripts,
    packageJsonPath.get(),
    fmt"{nodeModulesPath.get()}/.bin"
  )

