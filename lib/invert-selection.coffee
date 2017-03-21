{CompositeDisposable} = require 'atom'

zip = () ->
  # Zips to length of shortest array
  lengthArray = (arr.length for arr in arguments)
  length = Math.min(lengthArray...)
  for i in [0...length]
    arr[i] for arr in arguments

module.exports = InvertSelection =
  subscriptions: null

  activate: (state) ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'invert-selection:invert': => @invertSelection()

  deactivate: ->
    @subscriptions.dispose()
    @invertSelectionView.destroy()

  # serialize: ->
  #   invertSelectionViewState: @invertSelectionView.serialize()

  invertSelection: ->
    ## Invert current text selction in the editor
    console.log 'Invert selection activated'
    return unless editor = atom.workspace.getActiveTextEditor()

    selections = editor.getSelectionsOrderedByBufferPosition()
    ranges = []

    # Handle possible selection from the start
    initialPoint = selections[0].getBufferRange().start
    if not (initialPoint.row == 0 and initialPoint.column == 0)
      ranges.push([[0, 0], initialPoint])

    # Handle any number of selections in between
    if selections.length > 1
      for pair in zip(selections[0..-1], selections[1..])
        ranges.push([pair[0].getBufferRange().end, pair[1].getBufferRange().start])
        pair[0].clear(autoscroll: false)

    # Handle possible selection to the end
    finalPoint = selections[selections.length-1].getBufferRange().end
    lastRow = editor.getLastBufferRow()
    lastColumn = editor.lineTextForBufferRow(lastRow).length-1
    if not (finalPoint.row == lastRow and finalPoint.column == lastColumn)
      ranges.push([finalPoint, [lastRow, lastColumn]])

    # Deselect the old selection
    selections[selections.length-1].clear(autoscroll: false)

    # Select the new ranges
    for range in ranges
      editor.addSelectionForBufferRange(range, preserveFolds: true)
