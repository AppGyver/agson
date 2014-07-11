{Just, Nothing, fromNullable} = require 'data.maybe'

notImplemented = -> throw new Error 'not implemented'

# Lens a b
class Lens

  # a -> Store a b
  run: notImplemented

  # Lens b c -> Lens a c
  then: (bc) => lens (a) =>

    # c -> Maybe a
    set: (c) =>
      abs = @run(a) # Store a b
      abs.get().chain (b) ->
        bcs = bc.run(b) # Store b c
        bcs.set(c).chain (b) ->
          abs.set b

    # () -> Maybe c
    get: =>
      @run(a).get().chain (b) ->
        bc.run(b).get()

# Store a b
class Store

  # b -> Maybe a
  set: notImplemented

  # () -> Maybe b
  get: notImplemented

  # (b -> b) -> Maybe a
  modify: (f) ->
    @get().map(f).chain @set

# { set: b -> Maybe a, get: () -> Maybe b } -> Store a b
store = (s) ->
  new class extends Store
    set: s.set or notImplemented
    get: s.get or notImplemented
    modify: s.modify or Store::modify

# (a -> { set: b -> Maybe a, get: () -> Maybe b }) -> Lens a b
lens = (fs) ->
  new class extends Lens
    run: (a) -> store fs a

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

maybeMap = (xs, f) ->
  ys = []
  for x in xs
    maybeY = f x
    if maybeY.isJust
      ys.push maybeY.get()
  ys

traversal = (abl) -> lens (array) ->
  if !array?
    throw new TypeError "Input array must not be null"

  set: (v) -> @modify -> v

  modify: (f) ->
    Just maybeMap array, (a) ->
      abl.run(a).modify(f)

  get: ->
    Just maybeMap array, (a) ->
      abl.run(a).get()

module.exports = {
  nothing
  identity
  constant
  property
  traversal
}