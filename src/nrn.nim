import system
import std/[options, strformat, tables, sequtils, sugar, algorithm]

import args
import pkg
import run
import suggest

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

  let runned = run.run(
    nrnOptions,
    scripts,
    packageJsonPath.get(),
    fmt"{nodeModulesPath.get()}/.bin"
  )

  if not runned and nrnOptions.pmCommand == PmCommand.Run:
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

