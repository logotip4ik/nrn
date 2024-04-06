import system
import std/[os, osproc, strtabs, tables, paths, strformat, exitprocs]

import args
import pkg

proc exec(command: string, env: StringTableRef, workingDir: string) =
  let process = startProcess(
    command,
    env = env,
    options = {poEvalCommand, poParentStreams},
    workingDir = workingDir,
  )

  let noop = proc () {.noconv.} = discard
  let killProcess = proc () {.closure.} = kill(process)

  system.setControlCHook(noop)
  exitprocs.addExitProc(killProcess)

  discard waitForExit(process)

proc run*(options: args.Options, scripts: pkg.Scripts, packageJsonPath, binDirPath: string) =
  let file = paths.splitFile(Path(packageJsonPath))

  case options.pmCommand:
    of PmCommand.Run:
      if options.runCommand in scripts:
        let env = {
          "PATH": os.getEnv("PATH") & fmt":{binDirPath}"
        }.newStringTable()

        exec(scripts[options.runCommand], env, file.dir.string)
      discard
    else:
      discard

