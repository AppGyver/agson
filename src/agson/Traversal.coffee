{notImplemented, maybeFlatmap} = require './util'
Store = require './Store'
Lens = require './Lens'

# Traversable a => Traversal a b
module.exports = class Traversal extends Lens

  # (a -> { get, modify }) -> Traversal a b
  @of: (fs) ->
    new class extends Traversal
      run: (traversable) -> Store.of fs traversable

  then: (bc) => Traversal.of (a) =>

    modify: (f) =>
      @run(a).modify (mb) ->
        mb.chain (b) ->
          bc.run(b).modify f

    get: =>
      @run(a).get().map (bs) ->
        maybeFlatmap bs, (b) ->
          bc.run(b).get()
