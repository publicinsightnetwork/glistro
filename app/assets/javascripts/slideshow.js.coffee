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

      # save changes
      console.log("TODO: save", changes)

    # bind fields
    UTILS.bind '#slide-edit [name="title"]', -> MYSLIDE.$el.find('.slide-title')
    UTILS.bind '#slide-edit [name="desc"]', -> MYSLIDE.$el.find('.slide-desc')
    $('#slide-edit [name="layout"]').change ->
      UTILS.form2obj('#slide-edit', MYSLIDE.tmp) #get latest changes
      MYSLIDE.tmp.layout = this.value
      MYSLIDE.$el.html(UTILS.slideConfig(MYSLIDE.tmp).html)

    # file upload change
    $('#slide-edit input:file').change ->
      $('#slide-edit .imagename').val(this.value)
