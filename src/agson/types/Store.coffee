{Just} = require 'data.maybe'
{notImplemented} = require '../util'

# Monad m => Store m a
module.exports = class Store

  # { get, modify } -> Store m a
  @of: (M) -> (s) ->
    new class extends Store
      point: M.of
      modify: s.modify or notImplemented
      get: s.get or notImplemented

  # a -> m a
  point: notImplemented

  # (m a -> m b) -> m b
  modify: notImplemented

  # () -> m a
  get: notImplemented

  # b -> m b
  set: (b) ->
    @modify => @point b

  # (a -> b) -> m b
  map: (f) ->
    @modify (a) -> a.map f