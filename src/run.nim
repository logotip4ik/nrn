import system
import std/[os, osproc, strtabs, tables, paths, strformat, exitprocs, strutils, terminal]

import args
import pkg

type
  PM {.pure.} = enum
    Npm, Yarn, Pnpm, Bun

proc exec(command: string, env: StringTableRef, workingDir: string) =
  styledEcho styleBright, "$ ", styleDim, command , resetStyle, "\n"

  let process = startProcess(
    command,
    env = env,
    options = {poEvalCommand, poParentStreams, poInteractive, poDaemon},
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
  if os.fileExists(fmt"{root}/yarn.lock"):
    return PM.Yarn
  if os.fileExists(fmt"{root}/pnpm-lock.yaml"):
    return PM.Pnpm
  if os.fileExists(fmt"{root}/bun.lockb"):
    return PM.Yarn

  echo "Didn't found package manager, fallbacking to Yarn"
  return PM.Yarn

proc run*(options: args.Options, scripts: pkg.Scripts, packageJsonPath, binDirPath: string) =
  let packageJsonFile = paths.splitFile(Path(packageJsonPath))

  let env = newStringTable({
    "PATH": os.getEnv("PATH") & fmt":{binDirPath}",
  })

  case options.pmCommand:
    of PmCommand.Run:
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

    of PmCommand.Install:
      let pm = checkPm(packageJsonFile.dir.string)

      case pm:
        of PM.Npm:
          exec("npm install", env, packageJsonFile.dir.string)
        of PM.Yarn:
          exec("yarn install", env, packageJsonFile.dir.string)
        of PM.Pnpm:
          exec("pnpm install", env, packageJsonFile.dir.string)
        of PM.Bun:
          exec("bun install", env, packageJsonFile.dir.string)

    of PmCommand.Add:
      let pm = checkPm(packageJsonFile.dir.string)

      case pm:
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
      let pm = checkPm(packageJsonFile.dir.string)

      case pm:
        of PM.Npm:
          exec("npm remove" & options.forwarded, env, packageJsonFile.dir.string)
        of PM.Yarn:
          exec("yarn remove" & options.forwarded, env, packageJsonFile.dir.string)
        of PM.Pnpm:
          exec("pnpm remove" & options.forwarded, env, packageJsonFile.dir.string)
        of PM.Bun:
          exec("bun remove" & options.forwarded, env, packageJsonFile.dir.string)

