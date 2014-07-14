merge = require 'lodash-node/modern/objects/merge'
{Just, Nothing, fromNullable} = require 'data.maybe'

Lens = require './Lens'
lens = Lens.of

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
  modify: (f) ->
    mo.chain (object) ->
      mv = fromNullable(object[key])
      f(mv).chain (value) ->
        modification = {}
        modification[key] = value
        Just merge {}, object, modification
  get: ->
    mo.chain (object) ->
      fromNullable object[key]

# (a -> boolean) -> Lens a a
accept = (predicate) -> lens "predicate(#{predicate.toString()})", (ma) ->
  modify: (f) ->
    f(ma).chain (b) ->
      if predicate b
        Just b
      else
        Nothing()

  get: ->
    ma.chain (a) ->
      if predicate a
        Just a
      else
        Nothing()

# Lens a b -> (ma -> boolean)
definedAt = (abl) -> (ma) ->
  abl.run(ma).get().isJust

module.exports = {
  nothing
  identity
  constant
  property
  accept
  definedAt
}