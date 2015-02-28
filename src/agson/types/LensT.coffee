{notImplemented} = require '../util'
Store = require('./Store')

# (Monad m) => LensT m s a b = s -> StoreT m a b
module.exports = (Monad) ->
  class LensT
    Store: Store(Monad)

    constructor: ({@run, @toString}) ->

    # (description: String, s -> {
    #  get: () -> m a
    #  modify: (f: (m a) -> (m b)) -> m b
    # }) -> LensT m a b
    @of: (description, fs) ->
      new LensT(
        run: (a) -> @Store.of(fs a)
        toString: -> description
      )

    # Run the lens on a value
    # s -> StoreT m a b
    run: notImplemented

    # Chain this lens on another lens
    # (bc: LensT m b t c) -> LensT m s a c
    then: (bc) => LensT.of "#{@toString()}.then(#{bc.toString()})", (a) =>

      # (f: m c -> m d) -> m d
      modify: (f) =>
        @run(a).modify (b) ->
          bc.run(b).modify(f)

      # () -> m c
      get: =>
        @run(a).get().chain (b) ->
          bc.run(b).get()
