{Just} = require 'data.maybe'
{notImplemented} = require '../util'

# Monad m => Store m a
module.exports = (Monad) ->
  class StoreT
    constructor: ({@get, @modify}) ->

    # { get, modify } -> Store m a
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
      @modify -> Monad.of b

    # (a -> b) -> m b
    map: (f) ->
      @modify (a) -> a.map f
