merge = require 'lodash-node/modern/objects/merge'
{Just, Nothing, fromNullable} = require 'data.maybe'

Lens = require './Lens'
lens = Lens.of

nothing = lens ->
  modify: Nothing
  get: Nothing

identity = lens (a) ->
  modify: (f) -> f Just a
  get: -> Just a

constant = (value) -> lens ->
  modify: -> Just value
  get: -> Just value

property = (key) -> lens (object) ->
  unless object?
    nothing
  else
    modify: (f) ->
      fromNullable(object[key])
        .chain(f)
        .chain (value) ->
          modification = {}
          modification[key] = value
          Just merge {}, object, modification
    get: ->
      fromNullable object[key]

# (a -> boolean) -> Lens a a
accept = (predicate) -> lens (a) ->
  modify: (f) ->
    f(Just a).chain (b) ->
      if predicate b
        Just b
      else
        Nothing()

  get: ->
    if predicate a
      Just a
    else
      Nothing()

# Lens a b -> (a -> boolean)
definedAt = (abl) -> (a) ->
  abl.run(a).get().isJust

module.exports = {
  nothing
  identity
  constant
  property
  accept
  definedAt
}