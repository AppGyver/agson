{Just, Nothing, fromNullable} = require 'data.maybe'

lens = require('./types/Lens').of

nothing = lens "nothing", ->
  modify: Nothing
  get: Nothing

identity = lens "identity", (ma) ->
  modify: (f) -> f ma
  get: -> ma

constant = (value) -> lens "constant(#{value})", ->
  mv = fromNullable value
  modify: -> mv
  get: -> mv

property = (key) -> lens "property(#{key})", (object) ->
  setProperty = withProperty key

  modify: (f) ->
    mv = fromNullable(object[key])
    f(mv).chain (value) ->
      Just setProperty(object, value)
  get: ->
    fromNullable object?[key]

withProperty = (key) -> (object, value) ->
  result = {}
  for own k, v of object
    result[k] = v
  result[key] = value
  result

module.exports = {
  nothing
  identity
  constant
  property
}