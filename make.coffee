fs = require 'fs'
path = require 'path'
stringify = require 'json-stringify-pretty-compact'

dirname = 'font/solved'
font = {}

for filename in fs.readdirSync dirname
  continue unless filename.endsWith '.tsv'
  letter = filename[0].toUpperCase()
  pathname = path.join dirname, filename
  console.log letter, pathname

  ## Parse TSV
  tsv = fs.readFileSync pathname, encoding: 'utf8'
  table =
    for row in tsv.split '\n'
      row.split '\t'

  ## Add missing walls, assuming all numbers are on top and left
  wall = (char) ->
    if char == ''
      'x'
    else
      char
  wallRow = (row) ->
    [row[0], ...(wall char for char in row[1...-1]), row[row.length-1]]
  table[1] = wallRow table[1]
  table[table.length-2] = wallRow table[table.length-2]
  for row in table[1..]
    row[1] = wall row[1]
    row[row.length-1] = wall row[row.length-1]

  font[letter] = table

fs.writeFileSync 'font.js', stringify font
