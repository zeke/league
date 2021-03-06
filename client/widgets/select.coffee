# this only get set first off, it's not reactive right now (TODO)
Template.select.selected_text = ->
  unless @selected_text?
    selected_option = _.find(@options, (o) -> o.selected)
    text = selected_option.text if selected_option
    
    Meteor.deps.add_reactive_variable(this, 'selected_text', text) 
  
  @selected_text()
  
Template.select.events = 
  'change select': (event) ->
    @selected_text.set($(event.target).find('option:selected').text())
