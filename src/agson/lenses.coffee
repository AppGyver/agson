{Just, Nothing, fromNullable} = require 'data.maybe'

notImplemented = -> throw new Error 'not implemented'

# Traversal a b
class Traversal
  # a -> Store a b
  run: notImplemented

  # Traversal b c -> Traversal a c
  then: notImplemented

traversal = new class extends Traversal
  run: (traversable) ->
    store(
      set: (b) ->
        Just (
          b for a in traversable
        )

      modify: (f) ->
        Just (
          f a for a in traversable
        )
      
      get: ->
        Just traversable
    )

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

# { set, get, modify? } -> Store a b
store = (s) ->
  new class extends Store
    set: s.set or notImplemented
    get: s.get or notImplemented
    modify: s.modify or Store::modify

# (a -> { set, get, modify? }) -> Lens a b
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

# (a -> boolean) -> Lens a a
filter = (predicate) -> lens (a) ->
  set: (a) ->
    if predicate a
      Just a
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
  traversal
  filter
  definedAt
}