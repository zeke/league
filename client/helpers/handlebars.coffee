# unconfirmed, not_playing, playing
Handlebars.registerHelper 'availability_class', (status = 0) ->
  Game.playing_states[status].toLowerCase().replace(' ', '_')

Handlebars.registerHelper 'logo', (team, options) ->
  team.logo.render options.hash

# a per-field editing system; little hack here to deal with cases when record don't got an id
editing_field_name = (name, record) -> if record == window then false else "editing-#{record.id}-#{name}"
_current_edit_field = null
_current_edit_field_callback = null

# open a field and set a callback to be triggered when it closes
open_edit_field = (name, record) ->
  new_field = editing_field_name(name, record)
  return false if new_field == _current_edit_field or new_field == false
  
  # close the old field
  close_current_edit_field()
  
  # open the new one
  _current_edit_field = new_field
  console.log "opening edit field #{_current_edit_field}"
  Session.set(_current_edit_field, true)
  true
  
close_current_edit_field = ->
  Session.set(_current_edit_field, false) if _current_edit_field
  _current_edit_field = null

Handlebars.registerHelper 'equals', (left, right) -> 
  left.toString() == right.toString()

Handlebars.registerHelper 'if_with', (name, options) ->
  options.fn(name) if name

Handlebars.registerHelper 'if_editing', (name, options) ->
  if Session.equals(editing_field_name(name, this), true)
    options.fn(this)
  else
    options.inverse(this)

Handlebars.registerHelper 'pluralize', (word, count) ->
  if count == 1
    "#{count} #{word}"
  else
    "#{count} #{word}s"

Handlebars.registerHelper 'letter', (word) ->
  ("<span class='char#{i}'>#{letter}</span>" for letter, i in word.split('')).join('')

Handlebars.registerHelper 'fittext', (text, options)->
  key = (options.hash.key || Meteor.uuid()) + "-#{text}"
  new Handlebars.SafeString(Template.fittext({text: text, key: key}))
