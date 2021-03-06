{Just, Nothing, fromNullable} = require 'data.maybe'

lens = require('./Lens').of

nothing = lens "nothing", ->
  modify: Nothing
  get: Nothing

identity = lens "identity", (ma) ->
  modify: (f) -> f ma
  get: -> ma

constant = (value) -> lens "constant(#{value})", ->
  modify: -> fromNullable value
  get: -> fromNullable value

property = (key) -> lens "property(#{key})", (mo) ->
  setProperty = withProperty key

  modify: (f) ->
    mo.chain (object) ->
      mv = fromNullable(object[key])
      f(mv).chain (value) ->
        Just setProperty(object, value)
  get: ->
    mo.chain (object) ->
      fromNullable object[key]

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