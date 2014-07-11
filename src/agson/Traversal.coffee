{notImplemented} = require './util'
Store = require('./Store')

class ListStore extends Store
  # { get, modify, set? } -> Store a b
  @of: (s) ->
    new class extends ListStore
      modify: s.modify or notImplemented
      get: s.get or notImplemented

  set: (b) ->
    @modify -> b

# Traversable a => Traversal a b
module.exports = class Traversal
  # a -> Store a b
  run: notImplemented

  # Traversal b c -> Traversal a c
  then: (traversal) => Traversal.of (traversable) =>
    get: =>
      result = []
      for b in @run(traversable).get()
        result = result.concat traversal.run(b).get()
      result

    modify: (f) =>
      @run(traversable).modify (t) ->
        traversal.run(t).modify f

  # (a -> { get, modify, set? }) -> Traversal a b
  @of: (fs) ->
    new class extends Traversal
      run: (traversable) -> ListStore.of fs traversable