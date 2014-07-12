{Just, Nothing, fromNullable} = require 'data.maybe'

Lens = require './Lens'
lens = Lens.of

nothing = lens ->
  set: (b) -> Just b
  get: Nothing

identity = lens (a) ->
  set: (b) -> Just b
  get: -> Just a

constant = (value) -> lens ->
  set: -> Nothing()
  get: -> Just value

property = (key) -> lens (object) ->
  if !object?
    throw new TypeError "Input object must not be null"

  set: (value) ->
    # Warning: mutable!
    object[key] = value
    Just object
  get: ->
    fromNullable object[key]

# (a -> boolean) -> Lens a a
filter = (predicate) -> lens (a) ->
  set: (b) ->
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

# (Traversal a b) -> Lens a b
traverse = (traversal) -> lens (a) ->
  modify: (f) ->
    Just traversal.run(a).modify(f)
  set: (b) ->
    Just traversal.run(a).set(b)
  get: ->
    Just traversal.run(a).get()

module.exports = {
  nothing
  identity
  constant
  property
  filter
  definedAt
  traverse
}