import system
import std/[os, osproc, strtabs, tables, paths, strformat, exitprocs, strutils, terminal]

import args
import pkg

type
  PM {.pure.} = enum
    Npm, Yarn, Pnpm, Bun

proc exec(command: string, env: StringTableRef, workingDir: string) =
  styledEcho styleBright, "$ ", resetStyle, styleDim, command, resetStyle, "\n"

  let process = startProcess(
    command,
    env = env,
    options = {poEvalCommand, poParentStreams, poInteractive},
    workingDir = workingDir,
  )

  let noop = proc () {.noconv.} = discard
  let killProcess = proc () {.closure.} = kill(process)

  system.setControlCHook(noop)
  exitprocs.addExitProc(killProcess)

  discard waitForExit(process)

proc checkPm(root: string): PM =
  if os.fileExists(fmt"{root}/package-lock.json"):
    return PM.Npm
  if os.fileExists(fmt"{root}/yarn.lock") or os.fileExists(fmt"{root}/.yarnrc") or os.fileExists(fmt"{root}/.yarnrc.yml"):
    return PM.Yarn
  if os.fileExists(fmt"{root}/pnpm-lock.yaml"):
    return PM.Pnpm
  if os.fileExists(fmt"{root}/bun.lockb") or os.fileExists(fmt"{root}/bunfig.toml"):
    return PM.Yarn

  echo "Didn't found package manager, fallbacking to Npm"
  return PM.Npm

# returns true if had run at least one command
proc run*(options: args.Options, scripts: pkg.Scripts, packageJsonPath, binDirPath: string): bool =
  let packageJsonFile = paths.splitFile(Path(packageJsonPath))

  var env = newStringTable()
  for key, value in envPairs():
    env[key] = value

  result = true

  case options.pmCommand:
    of PmCommand.Run:
      env["PATH"] = os.getEnv("PATH") & fmt":{binDirPath}"
      env["npm_package_json"] = packageJsonPath
      env["npm_execpath"] = getAppDir() & getAppFilename()

      if options.runCommand in scripts:
        exec(
          scripts[options.runCommand] & options.forwarded,
          env,
          packageJsonFile.dir.string
        )
      elif os.fileExists(fmt"{binDirPath}/{options.runCommand}"):
        exec(
          options.runCommand & options.forwarded,
          env,
          packageJsonFile.dir.string
        )
      else:
        result = false
        styledEcho styleDim, "command not found: ", resetStyle, styleBright, options.runCommand, resetStyle

    of PmCommand.Install:
      case checkPm(packageJsonFile.dir.string):
        of PM.Npm:
          exec("npm install", env, packageJsonFile.dir.string)
        of PM.Yarn:
          exec("yarn install", env, packageJsonFile.dir.string)
        of PM.Pnpm:
          exec("pnpm install", env, packageJsonFile.dir.string)
        of PM.Bun:
          exec("bun install", env, packageJsonFile.dir.string)

    of PmCommand.Add:
      case checkPm(packageJsonFile.dir.string):
        of PM.Npm:
          exec("npm install" & options.forwarded, env, packageJsonFile.dir.string)
        of PM.Yarn:
          exec("yarn add" & options.forwarded, env, packageJsonFile.dir.string)
        of PM.Pnpm:
          exec("pnpm install" & options.forwarded, env, packageJsonFile.dir.string)
        of PM.Bun:
          let forwarded = options.forwarded.replaceWord("-D", "-d")
          exec("bun install" & forwarded, env, packageJsonFile.dir.string)

    of PmCommand.Remove:
      case checkPm(packageJsonFile.dir.string):
        of PM.Npm:
          exec("npm remove" & options.forwarded, env, packageJsonFile.dir.string)
        of PM.Yarn:
          exec("yarn remove" & options.forwarded, env, packageJsonFile.dir.string)
        of PM.Pnpm:
          exec("pnpm remove" & options.forwarded, env, packageJsonFile.dir.string)
        of PM.Bun:
          exec("bun remove" & options.forwarded, env, packageJsonFile.dir.string)
    else:
      result = false

proc printHelp*() =
  echo "Fast cross package manager scripts runner and more\n"
  styledEcho styleBright, styleUnderscore, "Usage:", resetStyle, styleBright, " nrn", resetStyle, " [OPTIONS] [command] [...script options]\n"
  styledEcho styleBright, styleUnderscore, "Arguments:"
  styledEcho "  [command] - package manager command (insatll, add, remove, run) or script to run. You can skip this as shorthand to ", styleBright, styleUnderscore, "run\n"
  styledEcho styleBright, styleUnderscore, "Options:"
  styledEcho styleBright, "  -h, --help", resetStyle, " - print this message\n"
  styledEcho styleBright, styleUnderscore, "Example:"
  styledEcho styleBright, "  nrn i", resetStyle, " - install dependencies with your package manager"
  styledEcho styleBright, "  nrn add yarn", resetStyle, " - install ", styleBright, "yarn", resetStyle, " at closest package.json"
  styledEcho styleBright, "  nrn rm pnpm", resetStyle, " - remove ", styleBright, "pnpm", resetStyle, " from closest package.json"
  styledEcho styleBright, "  nrn dev", resetStyle, " - run ", styleBright, "dev", resetStyle, " command from your package.json"
