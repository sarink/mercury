@Mercury.dialogHandlers.snippetPanel = ->
  # make the filter work
  @element.find('input.filter').on 'keyup', =>
    value = @element.find('input.filter').val()
    for item in @element.find('li[data-filter]')
      if LiquidMetal.score(jQuery(item).data('filter'), value) == 0 then jQuery(item).fadeOut(100) else jQuery(item).fadeIn(100)

  # when an element is dragged, set it so we have a global object
  @element.find('img[data-snippet]').on 'dragstart', ->
    Mercury.snippet = {name: jQuery(@).data('snippet'), hasOptions: !(jQuery(@).data('options') == false)}
    
  # delete snippet when user lets go
  @element.find('img[data-snippet]').on 'dragend', ->
