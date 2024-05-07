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

  let walk = pkg.walkUpPackages(nrnOptions.pmCommand == PmCommand.Run)
  var root: tuple[pkg: string, nm: string];
  var scripts: Scripts;

  if nrnOptions.pmCommand == PmCommand.Run:
    for packageJsonPath, nodeModulesPath in walk():
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

      styledEcho styleBright, "\nDid you mean?:"
      for i in countup(0, 2):
        if i < scripts.len:
          styledEcho " - ", styleItalic, maybeScipts[i][0]

      system.quit()
  else:
    let next = walk()
    root = (next.packageJson, next.nodeModules);

  run.run(
    nrnOptions,
    scripts,
    root.pkg,
    fmt"{root.nm}/.bin"
  )

