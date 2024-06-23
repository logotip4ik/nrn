import std/[parseopt, cmdline, sequtils, strutils, tables]

type
  PmCommand* {.pure.} = enum
    Run = "run"
    Add = "add"
    Install = "install"
    Remove = "remove"
    Help = "help"
  Options* = object of RootObj
    # rely on nim to set pmCommand to first value in PmCommand enum as default
    pmCommand*: PmCommand
    runCommand*: string
    forwarded*: string
    isScriptsCommand*: bool

const pmCommandAliases = {
  "i": PmCommand.Install,
  "r": PmCommand.Remove,
  "rm": PmCommand.Remove,
}.toTable()

const pmCommandsList = PmCommand.toSeq().mapIt($it)

proc getOptions*(): Options =
  var argv = initOptParser(commandLineParams())

  var checkedPmCommand = false
  for kind, key, val in argv.getopt():
    case kind:
      of CmdLineKind.cmdArgument:
        defer: checkedPmCommand = true

        if not checkedPmCommand:
          if pmCommandsList.contains(key):
            result.pmCommand = parseEnum[PmCommand](key)
          elif key in pmCommandAliases:
            result.pmCommand = pmCommandAliases[key]
          else:
            result.runCommand = key
        elif checkedPmCommand:
          result.forwarded.add(" " & key)

      of CmdLineKind.cmdLongOption:
        if checkedPmCommand:
          result.forwarded.add(
            if not val.isEmptyOrWhitespace(): " --" & key & "=" & val else: " --" & key
          )
        elif key == "help":
          result.pmCommand = PmCommand.Help
          break

      of CmdLineKind.cmdShortOption:
        if checkedPmCommand:
          result.forwarded.add(
            if not val.isEmptyOrWhitespace(): " -" & key & "=" & val else: " -" & key
          )
        elif key == "h":
          result.pmCommand = PmCommand.Help
          break

      of CmdLineKind.cmdEnd:
        break

  if not checkedPmCommand:
    result.pmCommand = PmCommand.Help
