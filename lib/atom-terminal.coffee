exec = require('child_process').exec
path = require('path')
platform = require('os').platform

module.exports =
    configDefaults: {
        app: 'Terminal.app'
        args: ''
        surpressDirectoryArgument: false
    },
    activate: ->
        atom.workspaceView.command "atom-terminal:open", => @open()

    open: ->
        filepath = atom.workspaceView.find('.tree-view .selected')?.view()?.getPath?()
        if filepath
            dirpath = path.dirname(filepath)
            app = atom.config.get('atom-terminal.app')
            args = atom.config.get('atom-terminal.args')

            cmdline = "#{app} #{args}"
            if !atom.config.get('surpressDirectoryArgument')
                cmdline  += "\"#{dirpath}\""

            if platform == "darwin"
                exec "open -a "+cmdline, cwd: dirpath if dirpath?
            else
                exec cmdline, cwd: dirpath if dirpath?
