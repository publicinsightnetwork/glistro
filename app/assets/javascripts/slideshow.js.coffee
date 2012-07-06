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
    $(this).tooltips('destroy')
    $(this).tooltips('reload')

    # disable map events on edit
    if $(this).hasClass('action-edit')
      $mapper.slideMapper('mapEvents', false);

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
    $('#slideshow-edit .cancel').click (e) ->
      e.preventDefault()
      endEdit($('#slideshow-edit'))

      #revert changes
      $('#slideshow-title').html(SLIDESHOW.title)
      $('#slideshow-desc').html(SLIDESHOW.desc)

    # save slideshow edit
    $('#slideshow-edit .save').click (e) ->
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
    $SLIDEINNER = null
    SLIDEINITIAL = null
    SLIDEDATA = null
    $('#slideshow').on 'click', '.edit', (e) ->
      e.preventDefault()
      $se = $('#slide-edit').css('margin-top', $('#slideshow').position().top+'px')
      startEdit($se)

      # configure
      $SLIDEINNER = $(this).closest('.slide-inner')
      SLIDEINITIAL = $SLIDEINNER.html()
      SLIDEDATA = null

      # get data
      slideId = $(this).attr('data-id')
      $.each SLIDESHOWCFG.slides, (idx, slide) ->
        SLIDEDATA = slide.data if (slide.data.id+'') == slideId
      SLIDEDATA.editing = true

      # set initial values
      $('#slide-edit [name="layout"]').val(SLIDEDATA.layout)
      $('#slide-edit [name="title"]').val(SLIDEDATA.title)
      $('#slide-edit [name="desc"]').val(SLIDEDATA.desc)
      $('#slide-edit [name="image_file_name"]').val(SLIDEDATA.image_file_name)

    # cancel slide edit
    $('#slide-edit .cancel').click (e) ->
      e.preventDefault()
      endEdit($('#slide-edit'))
      $SLIDEINNER.html(SLIDEINITIAL)
      $(this).tooltips('destroy')
      $(this).tooltips('reload')

    # slide changes
    # TODO: IE < 9 - http://stackoverflow.com/questions/7534890/can-jquery-check-whether-input-contents-has-changed
    $('#slide-edit [name="title"]').bind 'input', ->
      $SLIDEINNER.find('.slide-title').html(this.value)
    $('#slide-edit [name="desc"]').bind 'input', ->
      $SLIDEINNER.find('.slide-desc').html(this.value)

    # save slide edit
    $('#slide-edit .save').click (e) ->
      e.preventDefault()
      endEdit($('#slide-edit'))
      $(this).tooltips('destroy')
      $(this).tooltips('reload')

      # check for changes
      hasChanges = false
      if (SLIDEDATA.layout != (val = $('#slide-edit [name="layout"]').val()))
        hasChanges = SLIDEDATA.layout = val
      if (SLIDEDATA.title != (val = $('#slide-edit [name="title"]').val()))
        hasChanges = SLIDEDATA.title = val
      if (SLIDEDATA.desc != (val = $('#slide-edit [name="desc"]').val()))
        hasChanges = SLIDEDATA.desc = val
      return unless hasChanges
      alert("TODO: ajax save")

    # layout change
    $('#slide-edit [name="layout"]').change ->
      tpl = $(this).find("[value=\"#{this.value}\"]").attr('data-tpl')
      $SLIDEINNER.html(SMT["slides/#{tpl}"](SLIDEDATA))

    # file upload change
    $('#slide-edit input:file').change ->
      $('#slide-edit .imagename').val(this.value)
