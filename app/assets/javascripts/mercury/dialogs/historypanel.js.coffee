@Mercury.dialogHandlers.historyPanel = ->
  # make the filter work
  @element.find("input.filter").on "keyup", =>
    value = @element.find("input.filter").val()
    for item in @element.find("[data-filter]")
      if LiquidMetal.score(jQuery(item).data("filter"), value) == 0 then jQuery(item).fadeOut(100) else jQuery(item).fadeIn(100)