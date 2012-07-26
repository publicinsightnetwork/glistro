#
# Javascript utility functions
#
getJQ = (el) ->
  if el instanceof jQuery
    return el
  else if $.isFunction(el)
    return el()
  else
    return $(el)

# -----------------------------------------
#  Fly out a sidebar element
# -----------------------------------------
UTILS.flyOut = ($el, dir) ->
  $el = getJQ($el)
  $el.css
    width: $el.width+'px'
    height: $el.height+'px'
    position: 'absolute'
  .animate
    left: (if dir is 'left' then '-105%' else '105%')
    opacity: 0
  , 200, 'linear', ->
    $el.css('display', 'none')

# -----------------------------------------
#  Fly in a sidebar element
# -----------------------------------------
UTILS.flyIn = ($el, dir) ->
  $el = getJQ($el)
  $el.css
    width: ''
    height: ''
    position: 'relative'
    opacity: 0
    display: 'block'
    left: (if dir is 'left' then '-105%' else '105%')
  $el.animate
    left: '0%'
    opacity: 100
  , 200, 'linear', ->
    $el.find('input').first().select()


# -----------------------------------------
#  Start editing something
# -----------------------------------------
UTILS.startEdit = ($el) ->
  $el = getJQ($el)
  $('body').addClass('editing')
  SS.$map.slideMapper 'freeze', true
  UTILS.flyOut $('#slidenav'), 'right'
  UTILS.flyIn $el, 'left'

# -----------------------------------------
#  Stop editing something
# -----------------------------------------
UTILS.endEdit = ($el) ->
  $el = getJQ($el)
  $('body').removeClass('editing')
  SS.$map.slideMapper 'freeze', false
  UTILS.flyOut $el, 'left'
  UTILS.flyIn $('#slidenav'), 'right'

# -----------------------------------------
#  Fix tooltips for dynamic elements
# -----------------------------------------
UTILS.tips = ->
  $(this).tooltips('destroy')
  $(this).tooltips('reload')

# -----------------------------------------
#  Translate a slide object into a
#  slidemapper configuration
# -----------------------------------------
UTILS.LAYOUTS =
  T: 'textonly'
  L: 'imageleft'
  R: 'imageright'
  F: 'imagefull'
UTILS.slideConfig = (obj) ->
  marker: (if obj.marker_lat then [obj.marker_lat, obj.marker_lng] else null)
  center: null, #TODO
  zoom: null, #TODO
  html: SMT['slides/'+UTILS.LAYOUTS[obj.layout]](obj),
  popup: 'hello world'

# -----------------------------------------
#  Get the html markup for a slidenav card
# -----------------------------------------
UTILS.slideNavCard = (data) ->
  longDesc = data.desc || ''
  data.short_desc = longDesc.substring(0, 70).replace(/\w+$/, '').replace(/(<([^>]+)>)/ig, '')
  return SMT['slidenav/card'](data)

# -----------------------------------------
#  Get slide editing data for a certain ID
# -----------------------------------------
UTILS.slideEditData = ($btn) ->
  $btn = getJQ($btn)
  data = { $el: $btn.closest('.slide-inner') }
  sid = $btn.attr('data-id')
  $.each SS.SLIDES, (i, s) -> data.data = s if (s.id+'') == sid
  data.tmp = $.extend({}, data.data)
  return data

# -----------------------------------------
#  Update form elements from an object
# -----------------------------------------
UTILS.obj2form = (obj, $form) ->
  $form = getJQ($form)
  $.each obj, (key, val) -> $form.find("[name=\"#{key}\"]").val(val)

# -----------------------------------------
#  Update object from form element
# -----------------------------------------
UTILS.form2obj = ($form, obj) ->
  $form = getJQ($form)
  $.each obj, (key, val) ->
    if val = $form.find("[name=\"#{key}\"]").val()
      obj[key] = val

# -----------------------------------------
#  Get an object of changes made by the form
# -----------------------------------------
UTILS.form2changes = ($form, obj) ->
  $form = getJQ($form)
  changes = {}
  hasChanges = false
  $.each obj, (key, val) ->
    $field = $form.find("[name=\"#{key}\"]")
    if $field.length && $field.val() != val
      changes[key] = $field.val()
      hasChanges = true
  return (if hasChanges then changes else false)

# -----------------------------------------
#  Update html elements from an object
# -----------------------------------------
UTILS.obj2html = (obj, $html) ->
  $html = getJQ($html)
  $.each obj, (key, val) -> $html.find(".ss-#{key}").html(val)

# -----------------------------------------
#  Bind an input element to an html element,
#  so that changes can be seen live
#  TODO: IE < 9 - http://stackoverflow.com/questions/7534890/can-jquery-check-whether-input-contents-has-changed
# -----------------------------------------
UTILS.bind = ($input, $html, fn=null) ->
  $input = getJQ($input)
  $input.bind 'input', (if fn then fn else ->
    getJQ($html).html(this.value))

# -----------------------------------------
#  Mask a panel with a spinner gif
# -----------------------------------------
UTILS.mask = ($form) ->
  $form = getJQ($form)
  $form.prepend('<div class="save-mask"></div>') unless $form.find('.save-mask').length

# -----------------------------------------
#  Unmask a panel
# -----------------------------------------
UTILS.unmask = ($form) ->
  $form = getJQ($form)
  $form.find('.save-mask').remove()

# -----------------------------------------
#  Create a callback for ajax success
# -----------------------------------------
UTILS.remoteSuccess = ($form, obj, changes) ->
  $form = getJQ($form)
  $html = getJQ($html)
  return (data, textStatus, jqXHR) ->
    console.log("success", data, textStatus, jqXHR)
    UTILS.unmask($form)
    UTILS.endEdit($form)
    $.extend(obj, changes) #write changes

# -----------------------------------------
#  Create a callback for ajax errors
# -----------------------------------------
UTILS.remoteError = ($form, obj, changes) ->
  $form = getJQ($form)
  $html = getJQ($html)
  return (jqXHR, textStatus, errorThrown) ->
    console.error("remote error", jqXHR, textStatus, errorThrown)
    UTILS.unmask($form)
    UTILS.obj2form(obj, $form) #revert changes
    alert("Sorry... a remote error has occurred")

# -----------------------------------------
#  Move slidenav to a new index (css hack to redraw)
# -----------------------------------------
UTILS.moveNav = (index) ->
  $active = $('#slidenav ol li.active')
  unless $active.index() == index
    $active.removeClass('active')
    $active.css('display', 'none')
    $active.offset()
    $active.css('display', 'block')
    $('#slidenav ol li').eq(index).addClass('active')

# -----------------------------------------
#  Move slideshow to a new index
# -----------------------------------------
UTILS.moveSlide = (index) ->
  unless SS.$map.slideMapper('get').index == index
    SS.$map.slideMapper('move', index, true)

# -----------------------------------------
#  Fix slidenav numbering
# -----------------------------------------
UTILS.fixNumbers = ->
  $('#slidenav ol li .slide-number').each (idx, el) ->
    $(this).html(idx + 1)
