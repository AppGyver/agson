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

# Monad m -> Store m a b
module.exports = (Monad) ->
  class StoreT
    Monad: Monad
    
    constructor: ({@get, @set}) ->

    # { get, set } -> StoreT m a b
    @of: (s) ->
      new StoreT(
        get: s.get or StoreT::get
        set: s.set or StoreT::set
      )

    # m a -> m b
    set: notImplemented("set")

    # () -> m a
    get: notImplemented("get")

    # (Store m a b) -> c -> Store m c b
    extend: (f) ->
      new StoreT {
        get: => f this
        set: @set
      }

    # () -> m b
    from: -> @set @get()

    # (m b -> m c) -> Store m a c
    map: (f) ->
      new StoreT {
        get: @get
        set: (ma) => f @set ma
      }

    # (a -> c) -> Store m c b
    modify: (f) ->
      @extend (s) -> s.get().map f
