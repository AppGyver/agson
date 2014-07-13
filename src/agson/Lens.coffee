{notImplemented} = require './util'
Store = require('./Store')

class LensStore extends Store
  # { set, get, modify? } -> Store a b
  @of: (s) ->
    new class extends LensStore
      set: s.set or notImplemented
      get: s.get or notImplemented

  modify: (f) ->
    @get().map(f).chain @set

# Lens a b
module.exports = class Lens

  # (a -> { set, get, modify? }) -> Lens a b
  @of: (fs) ->
    new class extends Lens
      run: (a) -> LensStore.of fs a

  # a -> Store a b
  run: notImplemented

  # Lens b c -> Lens a c
  then: (bc) => Lens.of (a) =>

    # c -> Maybe a
    set: (c) =>
      abs = @run(a) # Store a b
      abs.get().chain (b) ->
        bcs = bc.run(b) # Store b c
        bcs.set(c).chain (b) ->
          abs.set b

    # () -> Maybe c
    get: =>
      @run(a).get().chain (b) ->
        bc.run(b).get()
