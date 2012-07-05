# slideshow show action
$ ->
  $("body.slideshows.action-show").each ->

    $mapper = $('#slideshow').slideMapper
      mapType: 'stamen-toner'
      controlType: 'top'
