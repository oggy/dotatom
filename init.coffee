Path = require 'path'

endBlock = (event) ->
  editor = atom.workspace.getActiveTextEditor()
  editor.insertText("end")
  editor.autoIndentSelectedRows()

# Override atom.workspace.updateWindowTitle to hack in our titles.
capitalize = (string) ->
  string.charAt(0).toUpperCase() + string.slice(1)

find = (obj, predicate) ->
  for value in obj
    if predicate.call(value)
      return value
  return null

buildTitle = (paths) ->
  names = paths.map (path) ->
    Path.basename(path).match(/[a-z0-9\.]+/ig).map(capitalize).join(' ')
  document.title = names.join(', ')

atom.workspace.updateWindowTitle = ->
  appName = 'Atom'
  projectPaths = atom.project?.getPaths() ? []
  if item = @getActivePaneItem()
    itemPath = item.getPath?()
    itemTitle = item.getTitle?()
    projectPath = find projectPaths, (projectPath) ->
      itemPath is projectPath or itemPath?.startsWith(projectPath + Path.sep)
  itemTitle ?= "untitled"
  projectPath ?= projectPaths[0]

  # console.log(projectPaths, buildTitle)
  # debugger
  document.title = buildTitle(projectPaths)
  if item? and projectPath?
    atom.setRepresentedFilename(itemPath ? projectPath)
  else if projectPath?
    atom.setRepresentedFilename(projectPath)
  else
    atom.setRepresentedFilename("")

atom.workspace.updateWindowTitle()

g = {}
g.__defineGetter__ 'ed', -> atom.workspace.getActiveTextEditor()
g.__defineGetter__ 'pane', -> atom.workspace.getActivePane()
g.__defineGetter__ 'item', -> atom.workspace.getActivePaneItem()
g.__defineGetter__ 'c', -> @ed.getCursor()
g.__defineGetter__ 'cs', -> @ed.getCursors()

window.g = g
