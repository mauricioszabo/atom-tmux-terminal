child = require 'child_process'
fs = require 'fs'

module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', 'tmux-terminal:send-window-contents': => @sendWindow()
    atom.commands.add 'atom-workspace', 'tmux-terminal:send-selection': => @sendSelection()
    atom.commands.add 'atom-workspace', 'tmux-terminal:send-custom-command': => @sendCommand()
    atom.commands.add 'atom-workspace', 'tmux-terminal:send-custom-command-with-position': => @sendCommand(true)
    atom.commands.add 'atom-workspace', 'tmux-terminal:send-break': => child.spawnSync('tmux', ['send-keys', 'C-c'])
    atom.commands.add 'atom-workspace', 'tmux-terminal:send-redo': => child.spawnSync('tmux', ['send-keys', 'Up', 'Enter'])

  sendWindow: ->
    child.spawnSync('tmux', ['send-keys', '-l', @editor().getText()])
    #editor.insertText('Hello, World!')

  sendSelection: ->
    for selection in @editor().selections
      child.spawnSync('tmux', ['send-keys', '-l', selection.getText()])

  sendCommand: (lineNumbers = false) ->
    homeTmux = process.env["HOME"] + "/.atom_tmux"
    projectTmux = atom.project.getDirectories()[0].getPath() + "/.atom_tmux"

    args = [atom.workspace.getActiveTextEditor().getPath()]
    if lineNumbers
      sel = atom.workspace.getActiveTextEditor().getLastCursor().getBufferPosition()
      args.push(sel.row + 1, sel.column + 1)

    result = if fs.existsSync(projectTmux)
      child.spawnSync(projectTmux, args).stdout.toString()
    else if fs.existsSync(homeTmux)
      child.spawnSync(homeTmux, args).stdout.toString()
    else
      JSON.stringfy([args[0]])

    result = JSON.parse(result)
    result.unshift('send-keys')
    result.unshift('-l')
    child.spawnSync('tmux', result)

  editor: ->
    atom.workspace.getActivePaneItem()
