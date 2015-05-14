---
---

createWorker = -> new Worker('lib/bms-compiler/worker.js')

worker = createWorker()

$ ->
  setupDropZone()

setupDropZone = ->
  $('.bt-dropzone')
  .text('Drop BMS file here')
  .on 'dragover', (e) -> e.preventDefault()
  .on 'dragenter', -> $(this).addClass('is-hover')
  .on 'dragleave', -> $(this).removeClass('is-hover')
  .on 'drop', (e) ->
    $(this).removeClass('is-hover')
    e.preventDefault()
    handleDrop(e)

log =
  clear: ->
    $('#bc-output').html('')
    return this
  puts: (text) ->
    $('#bc-output').append(
      if typeof text == 'string' then $('<li></li>').text(text) else text)
    return this


handleDrop = (e) ->
  file = e.originalEvent.dataTransfer?.files?[0]
  if file
    handleFile(file)
  else
    alert "Sorry: We could not recognize any dropped file!"

worker.onmessage = (e) ->
  for message in e.data.messages
    log.puts("[worker] #{message}")
  blob = new Blob([e.data.bms], type: 'text/plain;charset=utf-8')
  save = -> saveAs(blob, e.data.filename)
  log.puts($('<li>Downloading </li>')
    .append($('<strong></strong>')
      .append($('<a></a>')
        .attr('href', URL.createObjectURL(blob))
        .on('click', (e) -> save(); e.preventDefault())
        .text(e.data.filename))))
  save()

worker.onerror = (e) ->
  log.puts("[worker error] #{e.message}")

handleFile = (file) ->
  reader = new FileReader()
  log.clear().puts($('<li>Reading </li>')
    .append($('<strong></strong>').text(file.name)))
  reader.onload = ->
    log.puts($('<li>Processing </li>')
      .append($('<strong></strong>').text(file.name)))
    filename = file.name
    bms = reader.result
    worker.postMessage({ bms, filename })
  reader.onerror = ->
    log.puts('Error! Cannot read file.')
  reader.readAsText(file)

###
# test
$ ->
  bms = '''
    #00101:AABB
    #00101:CCDD
    #00116:Z2Z1
    #00151:00Z2
    #00251:Z200
  '''
  filename = 'foon_src.bms'
  worker = createWorker()
  worker.onmessage = (e) ->
    console.log e.data
  worker.postMessage({ bms, filename })
###
