import system
import std/[os, strformat, tables, sequtils, algorithm, terminal]

import args
import pkg
import run
import suggest

when isMainModule:
  var nrnOptions = args.getOptions()

  if nrnOptions.pmCommand == PmCommand.Help:
    run.printHelp()
    system.quit()

  var root: tuple[packageJson: string, nodeModules: string];
  var scripts: Scripts;

  if nrnOptions.pmCommand == PmCommand.Run:
    var availableScripts: seq[string] = @[];

    for packages in walkUpPackages():
      scripts = pkg.parseScriptsFromPackageJson(readFile(packages.packageJson))

      # TODO: in monorepo, this can cause issues, where some dependency is hoisted to the top node_modules.
      if nrnOptions.runCommand in scripts:
        nrnOptions.isScriptsCommand = true
        root = packages
        break
      elif os.fileExists(fmt"{packages.nodeModules}/.bin/{nrnOptions.runCommand}"):
        root = packages
        break
      else:
        availableScripts = availableScripts.concat(scripts.keys().toSeq())

    if root.packageJson.len == 0:
      styledEcho styleDim, "command not found: ", resetStyle, styleBright, nrnOptions.runCommand, resetStyle
      let maybeScipts = availableScripts
        .mapIt((it, suggest.fuzzyMatch(it, nrnOptions.runCommand)))
        .sortedByIt(it[1])
        .reversed()

      styledEcho styleBright, "\nDid you mean?:"
      for i in countup(0, 2):
        if i < scripts.len:
          styledEcho " - ", styleItalic, maybeScipts[i][0]

      system.quit()
  else:
    root = findClosestPackageJson();

  run.run(
    nrnOptions,
    scripts,
    root.packageJson,
    fmt"{root.nodeModules}/.bin"
  )

