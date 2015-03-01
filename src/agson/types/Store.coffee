{Just} = require 'data.maybe'
{notImplemented} = require '../util'

# Lens s t a b = Functor f => (a -> f b) -> s -> f t

# Functor f => Store s a
class Store
  # What did the lens focus on, if anything?
  # () -> f a
  view: notImplemented

  # Switch out the thing in focus.
  # (a -> f b) -> Store s b
  over: notImplemented

  # Put the focal point back into the larger structure.
  # () -> f s
  from: notImplemented

  # Set something in place of the focused thing.
  # (f b) -> Store s b
  set: notImplemented

  # Map the output as a whole to something else
  # (s -> t) -> Store t a
  map: notImplemented

  # Collapse anything in the Store to a single value.
  # (m -> (m -> a -> m)) -> Store m a
  fold: notImplemented

  # Extend the Store by calculating a new view of it
  # (Store s a -> f b) -> Store s b
  extend: notImplemented

# Monad m -> Store m a b
module.exports = (Monad) ->
  class StoreT
    Monad: Monad

    constructor: ({@get, @modify}) ->

    # { get, modify } -> StoreT m a b
    @of: (s) ->
      new StoreT(
        modify: s.modify or notImplemented
        get: s.get or notImplemented
      )

    # (m a -> m b) -> m b
    modify: notImplemented

    # () -> m a
    get: notImplemented

    # b -> m b
    set: (b) ->
      @modify (ma) ->
        ma.map ->
          b

    # (a -> b) -> m b
    map: (f) ->
      @modify (ma) ->
        ma.map f
