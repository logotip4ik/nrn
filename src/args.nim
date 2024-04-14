import std/[parseopt, cmdline, sequtils, strutils, strformat, tables]

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

const pmCommandAliases = {
  "i": PmCommand.Install,
  "rm": PmCommand.Remove,
}.toTable()

proc getOptions*(): Options =
  var argv = initOptParser(commandLineParams())
  var pmCommands = PmCommand.toSeq().mapIt($it)

  var checkedPmCommand = false
  for kind, key, val in argv.getopt():
    case kind:
      of CmdLineKind.cmdArgument:
        defer: checkedPmCommand = true

        if not checkedPmCommand:
          if pmCommands.contains(key):
            result.pmCommand = parseEnum[PmCommand](key)
          elif key in pmCommandAliases:
            result.pmCommand = pmCommandAliases[key]
          else:
            result.runCommand = key
        elif checkedPmCommand:
          result.forwarded.add(fmt" {key}")

      of CmdLineKind.cmdLongOption:
        if checkedPmCommand:
          result.forwarded.add(
            if not val.isEmptyOrWhitespace(): fmt" --{key}={val}" else: fmt" --{key}"
          )

      of CmdLineKind.cmdShortOption:
        if checkedPmCommand:
          result.forwarded.add(
            if not val.isEmptyOrWhitespace(): fmt" -{key}={val}" else: fmt" -{key}"
          )

      of CmdLineKind.cmdEnd:
        break
