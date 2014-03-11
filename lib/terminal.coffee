exec = require('child_process').exec
path = require('path')

module.exports =
    configDefaults: {
        app: 'Terminal.app'
        args: ''
    },
    activate: ->
        atom.workspaceView.command "terminal:open", => @open()

    open: ->
        filepath = atom.workspaceView.find('.tree-view .selected')?.view()?.getPath?()
        if filepath
            dirpath = path.dirname(filepath)
            app = atom.config.get('terminal.app')
            args = atom.config.get('terminal.args')
            exec "open -a #{app} #{args} #{dirpath}" if dirpath?
