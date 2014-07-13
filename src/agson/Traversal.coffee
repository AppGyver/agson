{notImplemented, maybeFlatmap} = require './util'
Store = require('./Store')
Lens = require './Lens'

class TraversalStore extends Store
  # { get, modify, set? } -> Store a b
  @of: (s) ->
    new class extends TraversalStore
      modify: s.modify or notImplemented
      get: s.get or notImplemented

  set: (b) ->
    @modify -> b

# Traversable a => Traversal a b
module.exports = class Traversal extends Lens

  # (a -> { get, modify, set? }) -> Traversal a b
  @of: (fs) ->
    new class extends Traversal
      run: (traversable) -> TraversalStore.of fs traversable

  then: (bc) => Traversal.of (a) =>

    modify: (f) =>
      @run(a).modify (b) ->
        bc.run(b).modify(f).getOrElse b

    get: =>
      @run(a).get().map (bs) ->
        maybeFlatmap bs, (b) ->
          bc.run(b).get()
