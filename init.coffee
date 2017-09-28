Path = require 'path'

# Custom window title

capitalize = (string) -> string.charAt(0).toUpperCase() + string.slice(1)
atom.workspace.onDidChangeWindowTitle ->
  paths = atom.project?.getPaths() ? []
  names = paths.map (path) ->
    Path.basename(path).match(/[a-z0-9\.]+/ig).map(capitalize).join(' ')
  title = names.join(', ')
  document.title = title
  document.querySelector('.title-bar .title').innerText = title
atom.workspace.updateWindowTitle()

# Custom commands

endBlock = (event) ->
  editor = atom.workspace.getActiveTextEditor()
  editor.transact ->
    editor.moveCursors (cursor) =>
      cursor.moveToEndOfLine()
      thisLineText = editor.lineTextForBufferRow(cursor.getBufferRow())
      unless /^\s*$/.test(thisLineText)
        pos = cursor.getBufferPosition()
        editor.setTextInBufferRange([pos, pos], '\n')
    editor.insertText("end")
    editor.autoIndentSelectedRows()

transposeLines = (event) ->
  editor = event.target?.closest('atom-text-editor').getModel()
  editor.transact ->
    for cursor in editor.getCursors()
      {row, column} = cursor.getBufferPosition()
      if cursor.getBufferRow() < editor.getLineCount() - 1
        text = editor.getTextInBufferRange([[row, 0], [row + 1, 0]])
        editor.deleteLine(row)
        editor.setTextInBufferRange([[row + 1, 0], [row + 1, 0]], text)
        cursor.setBufferPosition([row + 1, column])

toggleDevMode = ->
  devMode = not atom.inDevMode()
  atom.close()
  atom.open(pathsToOpen: atom.project.getPaths(), newWindow: true, devMode: devMode)

atom.commands.add 'atom-workspace', 'g:toggle-dev-mode', (event) -> toggleDevMode(event)
atom.commands.add 'atom-text-editor', 'g:end-block', (event) -> endBlock(event)
atom.commands.add 'atom-text-editor', 'g:transpose-lines', (event) -> transposeLines(event)

g = {}
g.__defineGetter__ 'ed', -> atom.workspace.getActiveTextEditor()
g.__defineGetter__ 'pane', -> atom.workspace.getActivePane()
g.__defineGetter__ 'item', -> atom.workspace.getActivePaneItem()
g.__defineGetter__ 'c', -> @ed.getCursors()[0]
g.__defineGetter__ 'cs', -> @ed.getCursors()
window.g = g
