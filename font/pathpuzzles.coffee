## 1 unit = 1 pt in Griddle.ai

plus = ->
  if @neighbor(-2,0).includes('+')
    x1 = -9
  else
    x1 = 0
  if @neighbor(+2,0).includes('+')
    x2 = 9
  else
    x2 = 0
  if @neighbor(0,-2).includes('+')
    y1 = -9
  else
    y1 = 0
  if @neighbor(0,+2).includes('+')
    y2 = 9
  else
    y2 = 0
  unless @neighbor(0,-2).includes('+') and @neighbor(0,+2).includes('+')
    x1 *= 2 unless @neighbor(-1,0).includes 's'
    x2 *= 2 unless @neighbor(+1,0).includes 's'
  unless @neighbor(-2,0).includes('+') and @neighbor(+2,0).includes('+')
    y1 *= 2 unless @neighbor(0,-1).includes 's'
    y2 *= 2 unless @neighbor(0,+1).includes 's'
  """
    <symbol viewBox="0 0 0 0" overflowBox="-9 -9 9 9" style="overflow: visible">
      <line x1="#{x1}" x2="#{x2}" stroke="black" stroke-width="1" />
      <line y1="#{y1}" y2="#{y2}" stroke="black" stroke-width="1" />
    </symbol>
  """

number = ->
  """
    <symbol viewBox="0 0 36 36" style="overflow: visible">
      <text style="font-family: Myriad Pro, sans-serif; font-size: 24" x="18" y="26" text-anchor="middle">
        #{@key}
      </text>
    </symbol>
  """

blank = ->
  #if @neighbor(+1,0).includes('+') or @neighbor(-1,0).includes('+')
  if @row().some((cell) -> cell.includes '+')
    '''
      <symbol viewBox="0 0 36 0">
      </symbol>
    '''
  #else if @neighbor(0,+1).includes('+') or @neighbor(0,-1).includes('+')
  else if @column().some((cell) -> cell.includes '+')
    '''
      <symbol viewBox="0 0 0 36">
      </symbol>
    '''
  else
    '''
      <symbol viewBox="0 0 36 36">
      </symbol>
    '''

solution = ->
  if @neighbor(+1,0).includes('+') or @neighbor(-1,0).includes('+') or
     @neighbor(0,+1).includes('+') or @neighbor(0,-1).includes('+')
    blank.call @
  else
    s = '<symbol viewBox="-18 -18 36 36" style="overflow: visible">\n'
    if @neighbor(+1,0).includes 's'
      s += '<line x2="18" stroke="black" stroke-width="3" stroke-linecap="round" />\n'
    if @neighbor(-1,0).includes 's'
      s += '<line x2="-18" stroke="black" stroke-width="3" stroke-linecap="round" />\n'
    if @neighbor(0,+1).includes 's'
      s += '<line y2="18" stroke="black" stroke-width="3" stroke-linecap="round" />\n'
    if @neighbor(0,-1).includes 's'
      s += '<line y2="-18" stroke="black" stroke-width="3" stroke-linecap="round" />\n'
    s += '</symbol>'
    s

ellipsis = '''
  <symbol viewBox="-18 -18 36 36">
    <circle r="2" fill="black" />
    <circle cx="-8" r="2" fill="black" />
    <circle cx="8" r="2" fill="black" />
  </symbol>
'''

(symbol) ->
  switch symbol
    when '+'
      plus
    when 's'
      solution
    when '...'
      ellipsis
    else
      if not isNaN parseInt symbol
        number
      else
        blank
