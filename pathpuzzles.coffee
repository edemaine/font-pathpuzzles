# These widths must match those in pathpuzzles.styl
majorWidth = 3/36
minorWidth = 1/36

plusLength = 9/36
wallLength = 1 - 2*plusLength  # 18/36 = 1/2
halfWallLength = wallLength / 2

class Puzzle
  constructor: (@cell) ->
    @edges = {}
  width: -> (@cell[0].length + 1) // 2
  height: -> (@cell.length + 1) // 2
  checkSolved: ->
    rects = []
    for xy of @clues
      rect = @checkClue xy
      return null unless rect?
      rects.push rect
    rects

class Display
  constructor: (@svg, @puzzle) ->
    @background = @svg.rect @puzzle.width() + 0.5, @puzzle.height() + 0.5
    .move -0.5, -0.5
    .addClass 'background'
    @solutionGroup = @svg.group()
    .addClass 'solution'
    @userGroup = @svg.group()
    .addClass 'user'
    @puzzleGroup = @svg.group()
    .addClass 'puzzle'
    @errorsGroup = @svg.group()
    .addClass 'errors'
    @drawPuzzle()
    @drawErrors()

  drawPuzzle: ->
    @puzzleGroup.clear()
    @solutionGroup.clear()
    @background.size @puzzle.width() + 0.5, @puzzle.height() + 0.5
    neighbor = (di, dj) => @puzzle.cell[i+di]?[j+dj] == '+'
    for row, i in @puzzle.cell
      y = i / 2
      for cell, j in row
        x = j / 2
        switch cell
          when '+'  # grid vertex
            @puzzleGroup.line(
              if neighbor 0, -2 then x - plusLength else x
              y
              if neighbor 0, +2 then x + plusLength else x
              y
            )
            @puzzleGroup.line(
              x
              if neighbor -2, 0 then y - plusLength else y
              x
              if neighbor +2, 0 then y + plusLength else y
            )
          when 'x'  # wall
            if i % 2 == 1 and j % 2 == 0
              @puzzleGroup.line x - halfWallLength, y, x + halfWallLength, y
            else if j % 2 == 1 and i % 2 == 0
              @puzzleGroup.line x, y - halfWallLength, x, y + halfWallLength
          when 's'  # solution
            if i % 2 == 1 and j % 2 == 0
              @solutionGroup.line x, y - 0.5, x, y + 0.5
            else if j % 2 == 1 and i % 2 == 0
              @solutionGroup.line x - 0.5, y, x + 0.5, y
          else
            int = parseInt cell
            unless isNaN int
              @puzzleGroup.rect 0.5, 0.66
              .center x, y
              @puzzleGroup.text cell
              .attr 'x', x
              .attr 'y', y + 8/36
    @svg.viewbox
      x: -0.5 - majorWidth/2
      y: -0.5 - majorWidth/2
      width: @puzzle.width() + 0.5 + majorWidth
      height: @puzzle.height() + 0.5 + majorWidth

  drawSolution: ->
    @solutionGroup.clear()

  drawErrors: ->
    @errorsGroup.clear()
    degree = {}
    increment = (x, y) ->
      degree[[x,y]] ?= 0
      degree[[x,y]]++
    for key, value of @puzzle.edges when value == true
      [x, y] = (parseFloat(z) for z in key.split ',')
      increment Math.floor(x), Math.floor(y)
      increment Math.ceil(x), Math.ceil(y)
    for key, value of degree when value > 2
      [x, y] = (parseFloat(z) for z in key.split ',')
      @errorsGroup.circle 0.33, 0.33
      .center x, y

add = (u,v) -> [u[0] + v[0], u[1] + v[1]]
sub = (u,v) -> [u[0] - v[0], u[1] - v[1]]
perp = (v) -> [-v[1], v[0]]

edge2dir = (edge) ->
  [
    edge[0] - Math.floor edge[0]
    edge[1] - Math.floor edge[1]
  ]

class Player extends Display
  constructor: (...args) ->
    super ...args
    @highlightEnable()
  highlightEnable: ->
    @lines = {}
    rt2o2 = Math.sqrt(2)/2
    @highlight = @svg.rect rt2o2, rt2o2
    .center 0, 0
    .addClass 'target'
    .opacity 0
    event2coord = (e) =>
      pt = @svg.point e.clientX, e.clientY
      rotated =
        x: rt2o2 * (pt.x + pt.y)
        y: rt2o2 * (-pt.x + pt.y)
      rotated.x /= rt2o2
      rotated.y /= rt2o2
      rotated.x -= 0.5
      rotated.y -= 0.5
      rotated.x = Math.round rotated.x
      rotated.y = Math.round rotated.y
      rotated.x += 0.5
      rotated.y += 0.5
      rotated.x *= rt2o2
      rotated.y *= rt2o2
      coord = [
        0.5 * Math.round 2 * rt2o2 * (rotated.x - rotated.y)
        0.5 * Math.round 2 * rt2o2 * (rotated.x + rotated.y)
      ]
      if 0 < coord[0] < @puzzle.width() and 0 < coord[1] < @puzzle.height() and
         @puzzle.cell[coord[1] * 2][coord[0] * 2] != 'x'
        coord
      else
        null
    event2cell = (e) =>
      pt = @svg.point e.clientX, e.clientY
      [
        Math.round pt.x
        Math.round pt.y
      ]
    event2corner = (e) =>
      pt = @svg.point e.clientX, e.clientY
      [
        0.5 + Math.round pt.x - 0.5
        0.5 + Math.round pt.y - 0.5
      ]
    @svg.on 'pointermove', (e) =>
      e.preventDefault()
      edge = event2coord e
      if edge?
        @highlight
        .transform
          rotate: 45
          translate: edge
        .opacity 0.333
        if e.buttons and @last?  # drag behavior
          unless (
            switch @last.state
              when true  # path
                cell = event2cell e
                cell[0] in [Math.floor(@last.edge[0]),
                            Math.ceil(@last.edge[0])] and
                cell[1] in [Math.floor(@last.edge[1]),
                            Math.ceil(@last.edge[1])]
              when false  # wall
                corner = event2corner e
                corner[0] in [0.5 + Math.floor(@last.edge[0] - 0.5),
                              0.5 + Math.ceil(@last.edge[0])] and
                corner[1] in [0.5 + Math.floor(@last.edge[1] - 0.5),
                              0.5 + Math.ceil(@last.edge[1] - 0.5)]
              when undefined  # erase
                false         # always
          )
            @toggle edge, @last.state
      else
        @highlight.opacity 0
    @svg.on 'pointerleave', (e) =>
      @highlight.opacity 0
      @last = undefined
    @svg.on 'pointerdown', (e) =>
      e.preventDefault()
      e.target.setPointerCapture e.pointerId
      edge = event2coord e
      return unless edge?
      @toggle edge,
        switch e.button
          when 0  # left click
            null  # => cycle through path, wall, empty
          when 1  # middle click
            false # => wall
          when 2  # right click
            undefined # => empty
          when 5  # pen eraser
            undefined # => empty
          else
            null
    for ignore in ['click', 'contextmenu', 'auxclick', 'dragstart', 'touchmove']
      @svg.on ignore, (e) -> e.preventDefault()
  toggle: (...args) ->
    for copy in @linked ? [@]
      copy.toggleSelf ...args
  toggleSelf: (edge, state) ->
    if @lines[edge]?
      @lines[edge].remove()
      delete @lines[edge]
    dir = edge2dir edge
    if state == null
      @puzzle.edges[edge] =
        switch @puzzle.edges[edge]
          when undefined
            true
          when true
            false
          when false
            undefined
    else
      @puzzle.edges[edge] = state
    if @puzzle.edges[edge] == false and
       not document.getElementById('walls').checked
      @puzzle.edges[edge] = undefined
    @last =
      edge: edge
      state: @puzzle.edges[edge]
    if @puzzle.edges[edge]?
      if @puzzle.edges[edge] == false
        dir = perp dir
      p = sub edge, dir
      q = add edge, dir
      @lines[edge] = @userGroup.line p..., q...
      .addClass if @puzzle.edges[edge] then 'path' else 'wall'
    @drawErrors()
    if solved = @puzzle.checkSolved()
      @svg.addClass 'solved'
    else
      @svg.removeClass 'solved'

fontGUI = ->
  app = new FontWebappHTML
    root: '#output'
    sizeSlider: '#size'
    charWidth: 225
    charPadding: 5
    charKern: 0
    lineKern: 22.5
    spaceWidth: 112.5
    shouldRender: (changed) ->
      changed.text
    renderChar: (char, state, parent) ->
      char = char.toUpperCase()
      letter = window.font[char]
      return unless letter?
      svg = SVG().addTo parent
      box = new Player svg, new Puzzle letter
    linkIdenticalChars: (glyphs) ->
      glyph.linked = glyphs for glyph in glyphs

  document.getElementById('reset').addEventListener 'click', ->
    app.render()

window?.onload = ->
  if document.getElementById 'output'
    fontGUI()

module?.exports = {Puzzle}
