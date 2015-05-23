exec = require('child_process').exec
path = require('path')
platform = require('os').platform

###
   Opens a terminal in the given directory, as specefied by the config
###
open_terminal = (dirpath) ->
  # Figure out the app and the arguments
  app = atom.config.get('atom-terminal.app')
  args = atom.config.get('atom-terminal.args')

  # get options
  setWorkingDirectory = atom.config.get('atom-terminal.setWorkingDirectory')
  surpressDirArg = atom.config.get('atom-terminal.surpressDirectoryArgument')
  runDirectly = atom.config.get('atom-terminal.MacWinRunDirectly')

  # Start assembling the command line
  cmdline = "\"#{app}\" #{args}"

  # If we do not supress the directory argument, add the directory as an argument
  if !surpressDirArg
      cmdline  += " \"#{dirpath}\""

  # For mac, we prepend open -a unless we run it directly
  if platform() == "darwin" && !runDirectly
    cmdline = "open -a " + cmdline

  # for windows, we prepend start unless we run it directly.
  if platform() == "win32" && !runDirectly
    cmdline = "start \"\" " + cmdline

  # log the command so we have context if it fails
  console.log("atom-terminal executing: ", cmdline)

  # Set the working directory if configured
  if setWorkingDirectory
    exec cmdline, cwd: dirpath if dirpath?
  else
    exec cmdline if dirpath?


module.exports =
    activate: ->
        atom.commands.add "atom-workspace", "atom-terminal:open", => @open()
        atom.commands.add "atom-workspace", "atom-terminal:open-project-root", => @openroot()
    open: ->
        editor = atom.workspace.getActivePaneItem()
        file = editor?.buffer?.file
        filepath = file?.path
        if filepath
            open_terminal path.dirname(filepath)
    openroot: ->
        open_terminal pathname for pathname in atom.project.getPaths()

# Set per-platform defaults
if platform() == 'darwin'
  # Defaults for Mac, use Terminal.app
  module.exports.config =
    app:
      type: 'string'
      default: 'Terminal.app'
    args:
      type: 'string'
      default: ''
    surpressDirectoryArgument:
      type: 'boolean'
      default: true
    setWorkingDirectory:
      type: 'boolean'
      default: true
    MacWinRunDirectly:
      type: 'boolean'
      default: false
else if platform() == 'win32'
  # Defaults for windows, use cmd.exe as default
  module.exports.config =
      app:
        type: 'string'
        default: 'C:\\Windows\\System32\\cmd.exe'
      args:
        type: 'string'
        default: ''
      surpressDirectoryArgument:
        type: 'boolean'
        default: true
      setWorkingDirectory:
        type: 'boolean'
        default: true
      MacWinRunDirectly:
        type: 'boolean'
        default: false
else
  # Defaults for all other systems (linux I assume), use xterm
  module.exports.config =
      app:
        type: 'string'
        default: '/usr/bin/x-terminal-emulator'
      args:
        type: 'string'
        default: ''
      surpressDirectoryArgument:
        type: 'boolean'
        default: true
      setWorkingDirectory:
        type: 'boolean'
        default: true
      MacWinRunDirectly:
        type: 'boolean'
        default: false
