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
    $el.find('input').first().select()

# dom ready
$ ->
  $("body.slideshows").each ->

    # init slidemapper
    $mapper = $('#slideshow').slideMapper(SLIDESHOWCFG)

    # start editing
    startEdit = ($el) ->
      $('body').addClass('editing')
      $mapper.slideMapper 'freeze', true
      flyOutSidebar $('#slidenav'), 'right'
      flyInSidebar $el, 'left'

    # end editing
    endEdit = ($el) ->
      $('body').removeClass('editing')
      $mapper.slideMapper 'freeze', false
      flyOutSidebar $el, 'left'
      flyInSidebar $('#slidenav'), 'right'

    # start slideshow edit
    $('#slideshow-actions .edit').click (e) ->
      e.preventDefault()
      $('#slideshow-edit input').val(SLIDESHOW.title)
      $('#slideshow-edit textarea').val(SLIDESHOW.desc)
      startEdit($('#slideshow-edit'))

    # slideshow changes
    # TODO: IE < 9 - http://stackoverflow.com/questions/7534890/can-jquery-check-whether-input-contents-has-changed
    $('#slideshow-edit input').bind 'input', ->
      $('#slideshow-title').html(this.value)
    $('#slideshow-edit textarea').bind 'input', ->
      $('#slideshow-desc').html(this.value)

    # cancel slideshow edit
    $('#slideshow-edit .button.secondary').click (e) ->
      e.preventDefault()
      endEdit($('#slideshow-edit'))

      #revert changes
      $('#slideshow-title').html(SLIDESHOW.title)
      $('#slideshow-desc').html(SLIDESHOW.desc)

    # save slideshow edit
    $('#slideshow-edit .button.success').click (e) ->
      e.preventDefault()
      endEdit($('#slideshow-edit'))

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

    # start slide edit
    EDITSLIDE = {}
    $('#slideshow').on 'click', '.edit', (e) ->
      e.preventDefault()
      $se = $('#slide-edit').css('margin-top', $('#slideshow').position().top+'px')
      startEdit($se)
      $act = $(this).closest('.slide-actions')
      EDITSLIDE.id = $act.attr('data-id')
      EDITSLIDE.el = $act.next('.slide-body')
      $.each SLIDESHOWCFG.slides, (idx, slide) ->
        EDITSLIDE.data = slide.data if (slide.data.id+'') == EDITSLIDE.id

      # set initial values
      $('#slide-edit [name="title"]').val(EDITSLIDE.data.title)
      $('#slide-edit [name="desc"]').val(EDITSLIDE.data.desc)

    # cancel slide edit
    $('#slide-edit .button.secondary').click (e) ->
      e.preventDefault()
      endEdit($('#slide-edit'))

      #revert changes
      EDITSLIDE.el.find('.slide-title').html(EDITSLIDE.data.title)
      EDITSLIDE.el.find('.slide-desc').html(EDITSLIDE.data.desc)

    # slide changes
    # TODO: IE < 9 - http://stackoverflow.com/questions/7534890/can-jquery-check-whether-input-contents-has-changed
    $('#slide-edit [name="title"]').bind 'input', ->
      EDITSLIDE.el.find('.slide-title').html(this.value)
    $('#slide-edit [name="desc"]').bind 'input', ->
      EDITSLIDE.el.find('.slide-desc').html(this.value)

    # save slide edit
    $('#slide-edit .button.success').click (e) ->
      e.preventDefault()
      endEdit($('#slide-edit'))

      # check for changes
      hasChanges = false
      if (EDITSLIDE.data.title != (val = $('#slide-edit [name="title"]').val()))
        hasChanges = EDITSLIDE.data.title = val
      if (EDITSLIDE.data.desc != (val = $('#slide-edit [name="desc"]').val()))
        hasChanges = EDITSLIDE.data.desc = val
      return unless hasChanges
      alert("TODO: ajax save")
