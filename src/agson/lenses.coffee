{Just, Nothing, fromNullable} = require 'data.maybe'

lens = require('./types/Lens').of

nothing = lens "nothing", ->
  set: Nothing
  get: Nothing

identity = lens "identity", (a) ->
  set: (ma) -> ma
  get: -> fromNullable a

constant = (value) -> lens "constant(#{value})", ->
  set: -> fromNullable value
  get: -> fromNullable value

property = (key) -> lens "property(#{key})", (object) ->
  set = setProperty(object, key)

  set: (mv) ->
    mv.map(set)
      .orElse(-> Just set null)
  get: -> fromNullable object?[key]

setProperty = (object, key) -> (value) ->
  result = {}
  
  for own k, v of object
    result[k] = v
  
  if value?
    result[key] = value
  else
    delete result[key]

  result

module.exports = {
  nothing
  identity
  constant
  property
}