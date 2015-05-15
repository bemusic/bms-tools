---
---

I18N = window.I18N =
  setLanguage: (language) ->
    I18N.strings = STRINGS[language]
    $(window).trigger('i18n')
  t: (keypath) ->
    string = I18N.strings
    for key in keypath.split('.')
      string = string?[key]
    if typeof string == 'string'
      string
    else
      undefined

$.fn.i18n = ->
  this.find('[data-i18n]').each ->
    keypath = this.getAttribute('data-i18n')
    $this = $(this)
    elements = { }
    $this.find('[data-element]').each ->
      elementKey = this.getAttribute('data-element')
      elements[elementKey] = this
    string = I18N.t(keypath)
    return unless string?
    this.innerHTML = string.replace(/\[\[(\w+)\]\]/, '<span data-element-placeholder="$1"></span>')
    $this.find('[data-element-placeholder]').each ->
      elementKey = this.getAttribute('data-element-placeholder')
      element = elements[elementKey]
      $(this).replaceWith(element) if element?
    $(this).i18n()
