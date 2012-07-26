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

      # update show title
      if changes.title
        $('#editing-alert strong').html(changes.title)

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
      allData = $.extend({}, MYSLIDE.data, changes)
      $newCard = $(UTILS.slideNavCard(allData)).addClass('active')
      $newCard.replaceAll('#slidenav ol li.active')
      UTILS.fixNumbers()

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
    #  Tie slidenav to slideshow
    # -----------------------------------------

    # slide changed
    SS.$map.on 'move', (e, slide, idx) ->
      UTILS.moveNav(idx)

    # nav changed
    $('#slidenav').on 'click', 'li', (e) ->
      idx = $(this).index()
      UTILS.moveSlide(idx)
      UTILS.moveNav(idx)

    # jump to slide-edit
    $('#slidenav').on 'click', 'li .slide-edit', (e) ->
      e.preventDefault()
      e.stopPropagation()

      idx = $(this).parent().index()
      UTILS.moveSlide(idx)
      UTILS.moveNav(idx)

      id = $(this).parent().attr('data-id')
      $('#slideshow .edit[data-id="'+id+'"]').click()

    # delete slide
    $('#slidenav').on 'click', 'li .slide-delete', (e) ->
      e.preventDefault()
      e.stopPropagation()
      idx = $(this).parent().index()
      wasActive = $(this).parent().hasClass('active')

      $(this).parent().fadeOut 150, ->
        $(this).remove()
        SS.$map.slideMapper('remove', idx)
        UTILS.fixNumbers()
        if wasActive
          newIdx = SS.$map.slideMapper('get').index
          $('#slidenav ol li').eq(newIdx).addClass('active')

      id = $(this).parent().attr('data-id')
      $.ajax "#{SS.SLIDESURL}/#{id}",
        dataType: 'json'
        type: 'delete'
        error: (jqXHR, textStatus, errorThrown) ->
          console.error("remote error", jqXHR, textStatus, errorThrown)
          alert("Sorry... a remote error has occurred")

    # add a new slide
    $('#slidenav .add-slide').click (e) ->
      e.preventDefault()
      $btn = $(this).addClass('disabled')

      $.ajax SS.SLIDESURL,
        dataType: 'json'
        type: 'post'
        data: {} #TODO
        error: (jqXHR, textStatus, errorThrown) ->
          $btn.removeClass('disabled')
          console.error("remote error", jqXHR, textStatus, errorThrown)
          alert("Sorry... a remote error has occurred")
        success: (data, textStatus, jqXHR) ->
          $btn.removeClass('disabled')
          SS.SLIDES.push(data)

          # add to map and slidenav
          data.editing = true
          SS.$map.slideMapper('add', UTILS.slideConfig(data))
          $newCard = $(UTILS.slideNavCard(data))
          $newCard.appendTo('#slidenav ol')
          $newCard.find('.slide-edit').click()
          UTILS.fixNumbers()
