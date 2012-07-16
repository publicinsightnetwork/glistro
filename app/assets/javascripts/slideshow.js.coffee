# -----------------------------------------
#  Show slideshow (minimal listeners)
# -----------------------------------------
$ ->
  $("body.slideshows.action-show").each ->

    # init slidemapper
    SS.$map = $('#slideshow').slideMapper(SS.SHOW.mapConfig)
    for s in SS.SLIDES
      SS.$map.slideMapper('add', UTILS.slideConfig(s))


# -----------------------------------------
#  Edit slideshow (lots of listeners)
# -----------------------------------------
$ ->
  $("body.slideshows.action-edit").each ->

    # init slidemapper
    SS.$map = $('#slideshow').slideMapper(SS.SHOW.mapConfig)
    SS.$map.slideMapper('mapEvents', false);
    for s in SS.SLIDES
      cfg = UTILS.slideConfig(s)
      cfg.editing = true
      SS.$map.slideMapper('add', UTILS.slideConfig(s))

    # fix tooltips
    UTILS.tips()


    # -----------------------------------------
    #  'show editing
    # -----------------------------------------

    $('#slideshow-actions .edit').click (e) ->
      e.preventDefault()
      UTILS.obj2form(SS.SHOW, '#slideshow-edit')
      UTILS.startEdit('#slideshow-edit')

    $('#slideshow-edit .cancel').click (e) ->
      e.preventDefault()
      UTILS.endEdit('#slideshow-edit')
      UTILS.obj2html(SS.SHOW, '#slideshow-info')

    $('#slideshow-edit .save').click (e) ->
      e.preventDefault()
      changes = UTILS.form2changes('#slideshow-edit', SS.SHOW)
      return UTILS.endEdit('#slideshow-edit') unless changes

      # save changes
      $.ajax SS.SHOWURL,
        dataType: 'json'
        type: 'put'
        data: {slideshow: changes}
        success: UTILS.remoteSuccess('#slideshow-edit', SS.SHOW, changes)
        error: UTILS.remoteError('#slideshow-edit', SS.SHOW, changes)

    # bind fields
    UTILS.bind '#slideshow-edit [name="title"]', '#slideshow-info .ss-title'
    UTILS.bind '#slideshow-edit [name="desc"]', '#slideshow-info .ss-desc'


    # -----------------------------------------
    #  slide editing
    # -----------------------------------------
    MYSLIDE = {}

    $('#slideshow').on 'click', '.edit', (e) ->
      e.preventDefault()
      MYSLIDE = UTILS.slideEditData(this)
      UTILS.obj2form(MYSLIDE.data, '#slide-edit')
      $('#slide-edit .imagename').val(MYSLIDE.data.slideimage.image_file_name) if MYSLIDE.data.slideimage
      UTILS.startEdit($('#slide-edit').css('margin-top', $('#slideshow').position().top+'px'))

    $('#slide-edit .cancel').click (e) ->
      e.preventDefault()
      UTILS.endEdit('#slide-edit')
      MYSLIDE.$el.html(UTILS.slideConfig(MYSLIDE.data).html)
      # UTILS.obj2html(MYSLIDE.data, MYSLIDE.$el)
      UTILS.tips()

    $('#slide-edit .save').click (e) ->
      e.preventDefault()
      changes = UTILS.form2changes('#slide-edit', MYSLIDE.data)
      return UTILS.endEdit('#slide-edit') unless changes

      # grab new image data, if it exists
      MYSLIDE.data.slideimage = MYSLIDE.tmp.slideimage if changes.slideimage_id

      # save changes
      $.ajax SS.SLIDESURL+'/'+MYSLIDE.data.id,
        dataType: 'json'
        type: 'put'
        data: {slide: changes}
        success: UTILS.remoteSuccess('#slide-edit', MYSLIDE.data, changes)
        error: UTILS.remoteError('#slide-edit', MYSLIDE.data, changes)

      # refresh card
      if MYSLIDE.data.slideimage
        sim = MYSLIDE.data.slideimage
        $('#slidenav ol li.active').html("<img alt=\"#{sim.image_file_name}\" src=\"#{sim.square_url}\"/>")
      else
        title = changes.title || MYSLIDE.data.title
        desc = changes.desc || MYSLIDE.data.desc
        desc = desc.substring(0, 70).replace(/\w+$/, '').replace(/(<([^>]+)>)/ig, '')
        $('#slidenav ol li.active').html("<b>#{title}</b> #{desc}")

    # bind fields
    UTILS.bind '#slide-edit [name="title"]', -> MYSLIDE.$el.find('.slide-title')
    UTILS.bind '#slide-edit [name="desc"]', -> MYSLIDE.$el.find('.slide-desc')
    $('#slide-edit [name="layout"]').change ->
      UTILS.form2obj('#slide-edit', MYSLIDE.tmp) #get latest changes
      MYSLIDE.tmp.layout = this.value
      MYSLIDE.$el.html(UTILS.slideConfig(MYSLIDE.tmp).html)


    # -----------------------------------------
    #  image uploading
    # -----------------------------------------

    $("#slide-edit input:file").fileupload
      url: '/upload.json'
      dataType: 'json'
      replaceFileInput: false
      formData: {}
      add: (e, data) ->
        file = data.files[0]
        $('#slide-edit .imagename').val(file.name || 'unknown')
        $('#slide-edit .uploading').fadeIn 200
        data.start = e.timeStamp
        data.submit()
        console.log("TODO: validation", e, data, file)
      progress: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        progress = Math.max(progress, 1)
        console.log("TODO: PROGRESS", data.loaded, data.total, progress+'%')
      done: (e, data) ->
        duration = 1000 - (e.timeStamp - data.start)
        duration = Math.max(duration, 0)
        $('#slide-edit .uploading').delay(duration).fadeOut 200, ->
          UTILS.form2obj('#slide-edit', MYSLIDE.tmp) #get latest changes
          MYSLIDE.tmp.slideimage = data.result
          MYSLIDE.tmp.slideimage_id = data.result.id
          $('#slide-edit [name="slideimage_id"]').val(data.result.id)
          MYSLIDE.$el.html(UTILS.slideConfig(MYSLIDE.tmp).html)
          console.log("DONE", data, data.result)


    # -----------------------------------------
    #  'show editing
    # -----------------------------------------

    SS.$map.on 'move', (e, slide, idx) ->
      $active = $("#slidenav ol li[data-index=#{idx}]")
      unless $active.hasClass('active')
        $('#slidenav ol li').removeClass('active')
        $active.addClass('active')

    $('#slidenav').on 'click', 'li', (e) ->
      $('#slidenav ol li').removeClass('active')
      $(this).addClass('active')
      idx = $(this).attr('data-index')
      SS.$map.slideMapper('move', parseInt(idx), true)
