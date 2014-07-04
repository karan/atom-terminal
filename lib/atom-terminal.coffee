exec = require('child_process').exec
path = require('path')
platform = require('os').platform



module.exports =
    activate: ->
        atom.workspaceView.command "atom-terminal:open", => @open()
    open: ->
        filepath = atom.workspaceView.find('.tree-view .selected')?.view()?.getPath?()
        if filepath
            dirpath = path.dirname(filepath)

            # Figure out the app and the arguments
            app = atom.config.get('atom-terminal.app')
            args = atom.config.get('atom-terminal.args')

            # Do we want to set the working directory?
            setWorkingDirectory = atom.config.get('atom-terminal.setWorkingDirectory')

            # Start assembling the command line
            cmdline = "#{app} #{args}"

            # If we do not supress the directory argument, add the directory as an argument
            if !atom.config.get('surpressDirectoryArgument')
                cmdline  += "\"#{dirpath}\""

            # For mac, we prepend open -a unless we run it directly
            if platform() == "darwin" && !atom.config.get('MacWinRunDirectly')
              cmdline = "open -a " + cmdline

            # for windows, we prepend start unless we run it directly.
            if platform() == "win32" && !atom.config.get('MacWinRunDirectly')
              cmdline = "start " + cmdline

            # Set the working directory if configured
            if setWorkingDirectory
              exec cmdline, cwd: dirpath if dirpath?
            else
              exec cmdline if dirpath?

# Set per-platform defaults
if platform() == 'darwin'
  # Defaults for Mac, use Terminal.app
  module.exports.configDefaults = {
        app: 'Terminal.app'
        args: ''
        surpressDirectoryArgument: false
        setWorkingDirectory: false
        MacWinRunDirectly: false
  }
else if platform() == 'win32'
  # Defaults for windows, use cmd.exe as default
  module.exports.configDefaults = {
        app: 'C:\Windows\System32\cmd.exe'
        args: ''
        surpressDirectoryArgument: false
        setWorkingDirectory: true
        MacWinRunDirectly: false
  }
else
    # Defaults for all other systems (linux I assume), use xterm
    module.exports.configDefaults = {
        app: '/usr/bin/xterm'
        args: ''
        surpressDirectoryArgument: false
        setWorkingDirectory: true
        MacWinRunDirectly: false
    }
