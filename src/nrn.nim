import system
import std/[os, strformat, tables, sequtils, sugar, algorithm, terminal]

import args
import pkg
import run
import suggest

when isMainModule:
  var nrnOptions = args.getOptions()

  if nrnOptions.pmCommand == PmCommand.Help:
    run.printHelp()
    system.quit()

  let packageJsonPaths = pkg.findFile("package.json", nrnOptions.pmCommand != PmCommand.Run)
  let nodeModulesPaths = pkg.findFolder("node_modules", nrnOptions.pmCommand != PmCommand.Run)

  if packageJsonPaths.len == 0:
    echo "no package.json found in tree"
    system.quit()

  if nodeModulesPaths.len == 0 and nrnOptions.pmCommand != PmCommand.Install:
    echo "no node_modules found in tree"
    system.quit()

  var root: tuple[pkg: string, nm: string];
  var scripts: Scripts;

  if nrnOptions.pmCommand == PmCommand.Run:
    for i in countup(0, min(packageJsonPaths.len, nodeModulesPaths.len) - 1):
      let packageJsonPath = packageJsonPaths[i]
      let nodeModulesPath = nodeModulesPaths[i]

      scripts = pkg.parseScriptsFromPackageJson(readFile(packageJsonPath))

      if nrnOptions.runCommand in scripts:
        nrnOptions.isScriptsCommand = true
        root = (packageJsonPath, nodeModulesPath)
        break
      elif os.fileExists(fmt"{nodeModulesPath}/.bin/{nrnOptions.runCommand}"):
        root = (packageJsonPath, nodeModulesPath)
        break

    if root.pkg.len == 0:
      styledEcho styleDim, "command not found: ", resetStyle, styleBright, nrnOptions.runCommand, resetStyle
      let maybeScipts = scripts
        .keys()
        .toSeq()
        .map((it: string) => (it, suggest.fuzzyMatch(it, nrnOptions.runCommand)))
        .sortedByIt(it[1])
        .reversed()

      echo "Did you mean?:"
      for i in countup(0, 2):
        if i < scripts.len:
          echo " - ", maybeScipts[i][0]

      system.quit()
  else:
    root = (packageJsonPaths[0], nodeModulesPaths[0])

  run.run(
    nrnOptions,
    scripts,
    root.pkg,
    fmt"{root.nm}/.bin"
  )

