{notImplemented} = require './util'
Store = require('./Store')

# Lens a b
module.exports = class Lens

  # (a -> { get, modify }) -> Lens a b
  @of: (fs) ->
    new class extends Lens
      run: (a) -> Store.of fs a

  # a -> Store Maybe b
  run: notImplemented

  # Lens b c -> Lens a c
  then: (bc) => Lens.of (a) =>

    # (c -> c) -> Maybe a
    modify: (f) =>
      @run(a).modify (b) ->
        bc.run(b).modify(f)

    # () -> Maybe c
    get: =>
      @run(a).get().chain (b) ->
        bc.run(b).get()
