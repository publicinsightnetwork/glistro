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
  , 200, 'linear', ->
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
  , 200, 'linear', ->
    $el.find('input').select()

# dom ready
$ ->
  $("body.slideshows").each ->

    # init slidemapper
    $mapper = $('#slideshow').slideMapper(SLIDESHOWCFG)

    # start slideshow edit
    $('#slideshow-actions .edit').click (e) ->
      e.preventDefault()
      $mapper.slideMapper 'keyEvents', false
      $('#slideshow-edit input').val(SLIDESHOW.title)
      $('#slideshow-edit textarea').val(SLIDESHOW.desc)
      flyOutSidebar $('#slidenav'), 'right'
      flyInSidebar $('#slideshow-edit'), 'left'
      $('body').addClass('editing')

    # slideshow changes
    # TODO: IE < 9 - http://stackoverflow.com/questions/7534890/can-jquery-check-whether-input-contents-has-changed
    $('#slideshow-edit input').bind 'input', ->
      $('#slideshow-title').html(this.value)
    $('#slideshow-edit textarea').bind 'input', ->
      $('#slideshow-desc').html(this.value)

    # cancel slideshow edit
    $('#slideshow-edit .button.secondary').click (e) ->
      e.preventDefault()
      $('body').removeClass('editing')
      $mapper.slideMapper 'keyEvents', true
      flyOutSidebar $('#slideshow-edit'), 'left'
      flyInSidebar $('#slidenav'), 'right'

    # save slideshow edit
    $('#slideshow-edit .button.success').click (e) ->
      e.preventDefault()
      $('#slideshow-edit .button.secondary').click() # end edit

      # check for changes
      hasChanges = false
      if (SLIDESHOW.title != (val = $('#slideshow-edit input').val()))
        hasChanges = SLIDESHOW.title = val
      if (SLIDESHOW.desc != (val = $('#slideshow-edit textarea').val()))
        hasChanges = SLIDESHOW.desc = val
      return unless hasChanges

      # save changes
      $.ajax SLIDESHOWURL,
        dataType: 'json'
        type: 'put'
        data:
          slideshow:
            title: SLIDESHOW.title
            desc: SLIDESHOW.desc
        success: (data, textStatus, jqXHR) ->
          console.log("SUCCESS", data, textStatus, jqXHR)
        error: (jqXHR, textStatus, errorThrown) ->
          console.error("FAILURE", jqXHR, textStatus, errorThrown)

