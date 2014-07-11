{notImplemented} = require './util'

# Monad m => Store m a b
module.exports = class Store

  # b -> m a
  set: notImplemented

  # () -> m b
  get: notImplemented

  # (b -> b) -> m a
  modify: notImplemented
