# slideshow page

# fly-out a sidebar
flyOutSidebar = ($el, dir) ->
  $el.css
    width: $el.width+'px'
    height: $el.height+'px'
    position: 'absolute'
  .animate
    left: (if dir is 'left' then '-105%' else '105%')
    opacity: 0
  , 300, 'linear', ->
    $el.css('display', 'none')

# fly-in a sidebar
flyInSidebar = ($el, dir) ->
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
  , 300, 'linear'

# dom ready
$ ->
  $("body.slideshows").each ->

    # init slidemapper
    $mapper = $('#slideshow').slideMapper(SLIDESHOWCFG)

    # start slideshow edit
    $('#slideshow-actions .edit').click (e) ->
      e.preventDefault()
      flyOutSidebar $('#slidenav'), 'right'
      flyInSidebar $('#slideshow-edit'), 'left'
      $('body').addClass('editing')

    # cancel slideshow edit
    $('#slideshow-edit .button.secondary').click (e) ->
      e.preventDefault()
      flyOutSidebar $('#slideshow-edit'), 'left'
      flyInSidebar $('#slidenav'), 'right'
      $('body').removeClass('editing')
