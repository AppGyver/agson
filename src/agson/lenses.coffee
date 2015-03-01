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

property = (key) -> lens "property(#{key})", (mo) ->
  setProperty = withProperty key
  removeProperty = withoutProperty key
  maybeKey = propertyFromObject key

  modify: (f) ->
    mo.chain (object) ->
      f(maybeKey object)
        .map((value) -> setProperty object, value)
        .orElse(-> Just removeProperty object)

  get: ->
    mo.chain maybeKey

withProperty = (key) -> (object, value) ->
  result = {}
  for own k, v of object
    result[k] = v
  result[key] = value
  result

withoutProperty = (key) -> (object) ->
  result = {}
  for own k, v of object when k isnt key
    result[k] = v
  result

propertyFromObject = (key) -> (object) ->
  fromNullable object?[key]

module.exports = {
  nothing
  identity
  constant
  property
}