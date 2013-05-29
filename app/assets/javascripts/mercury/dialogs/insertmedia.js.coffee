@Mercury.dialogHandlers.insertMedia = ->
  # initialize the jQuery File Upload widget
  $form = @element.find("#mercury-fileupload")
  $form.fileupload()
  
  top.jQuery.getJSON($form.prop("action"), (files) ->
    # load existing files
    fu = $form.data("blueimpFileupload")
    fu._adjustMaxNumberOfFiles(-files.length)
    $template = fu._renderDownload(files).appendTo($form.find(".files"))
    # force reflow
    fu._reflow = fu._transition and $template.length and $template[0].offsetWidth
    $template.addClass("in")
    
  ).complete ->
    # remove loading spinner
    jQuery("#loading").remove()
    # make the filter work
    $form.find("input.filter").on "keyup", =>
      value = $form.find("input.filter").val()
      for item in $form.find("[data-filter]")
        if LiquidMetal.score(jQuery(item).data("filter"), value) == 0 then jQuery(item).fadeOut(100) else jQuery(item).fadeIn(100)