---
---

process = (input) ->
  lines = input.trim().split(/\r\n|\r|\n/).map((x) -> { text: x.trim() })
  data = { }
  get = (row) -> data[row] or= { k: [ ], b: { } }
  stderr = []
  replaced = 0
  for line in lines
    m = line.text.match(/(\d+) (\d+) (\d+) (\d+) (\d+)/)
    if m
      row = m[2]
      if (4 <= +m[1] <= 20) and +m[3] >= 12610000
        get(row).k.push({ line, index: (m[3] / 10000) - 1260 })
      else if 26 <= +m[1]
        get(row).b[m[1] - 25] = { line, value: m[3] }
  for row, { k, b } of data
    for { index, line } in k
      if b[index]
        { line: found_line, value } = item = b[index]
        if item.used
          stderr.push('Waning at row ' + row + ': Reused column B' + index)
        item.used = true
        found_line.text = null
        line.text = line.text.replace /^(\d+ \d+) (\d+)/, (a, x, y) ->
          "#{x} #{value}"
        replaced += 1
      else
        stderr.push('Warning at row ' + row + ': Unknown column B' + index)
  stderr.push('Replaced ' + replaced + ' note(s)')
  [lines.map(({ text }) -> if text then text + '\n' else '').join(''),
      stderr.join('\n')]

go = ->
  [stdout, stderr] = process($('#bt-in').val())
  $('#bt-out').val(stdout)
  $('#bt-err').text(stderr)

go()

$ ->
  $('<button class="btn btn-primary">Process</button>')
      .click(go).appendTo('#bt-go')
