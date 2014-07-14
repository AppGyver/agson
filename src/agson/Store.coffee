{Just} = require 'data.maybe'
{notImplemented} = require './util'

# Monad m => Store m a
module.exports = class Store

  # { get, modify } -> Store m a
  @of: (M) -> (s) ->
    new class extends Store
      M: M
      modify: s.modify or notImplemented
      get: s.get or notImplemented

  # () -> m a
  get: notImplemented

  # (m a -> m b) -> m b
  modify: notImplemented

  # b -> m b
  set: (b) ->
    @modify -> M.of b

  # (a -> b) -> m b
  map: (f) ->
    @modify (a) -> a.map f