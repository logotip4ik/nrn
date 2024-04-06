import std/[parseopt, cmdline, sequtils, strutils, strformat]

type
  PmCommand* {.pure.} = enum
    Run = "run"
    Add = "add"
    Install = "install"
    Remove = "remove"
  Options* = object
    # rely on nim to set pmCommand to first value in PmCommand enum as default
    pmCommand*: PmCommand
    runCommand*: string
    forwarded*: string

proc getOptions*(): Options =
  var argv = initOptParser(commandLineParams())
  var pmCommands = PmCommand.toSeq().mapIt($it)

  var checkedPmCommand = false
  var forwarding = false
  for kind, key, val in argv.getopt():
    case kind:
      of CmdLineKind.cmdArgument:
        defer: checkedPmCommand = true

        if not checkedPmCommand:
          if pmCommands.contains(key): result.pmCommand = parseEnum[PmCommand](key)
          else: result.runCommand = key
        elif forwarding:
          result.forwarded.add(fmt" {key}")

      of CmdLineKind.cmdLongOption:
        if forwarding == true:
          result.forwarded.add(fmt" --{key}={val}")

        if key.isEmptyOrWhitespace():
          forwarding = true

      of CmdLineKind.cmdShortOption:
        if forwarding == true:
          result.forwarded.add(fmt" -{key}={val}")

      of CmdLineKind.cmdEnd:
        break
