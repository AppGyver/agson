{Just} = require 'data.maybe'
{notImplemented} = require '../util'

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
