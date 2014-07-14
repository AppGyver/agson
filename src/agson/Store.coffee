{Just} = require 'data.maybe'
{notImplemented} = require './util'

# Monad m => Store m a
module.exports = class Store

  # { get, modify } -> Store m a
  @of: (s) ->
    new class extends Store
      modify: s.modify or notImplemented
      get: s.get or notImplemented

  # () -> m a
  get: notImplemented

  # (m a -> m b) -> m b
  modify: notImplemented

  # b -> m b
  set: (b) ->
    @modify -> Just b

  # (a -> b) -> m b
  map: (f) ->
    @modify (a) -> a.map f