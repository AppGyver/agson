{notImplemented} = require '../util'
Store = require('./Store')

# Monad m => LensT m a b = a -> StoreT m a b
module.exports = (Monad) ->
  class LensT
    Store: Store(Monad)

    constructor: ({@runM, @toString}) ->

    # (m a -> { get, modify }) -> LensT m a b
    @of: (description, fs) ->
      new LensT(
        runM: (ma) -> @Store.of(fs ma)
        toString: -> description
      )

    # m a -> StoreT m a b
    runM: notImplemented

    # a -> Store Maybe b
    run: (a) -> @runM Monad.of a

    # LensT m b c -> LensT m a c
    then: (bc) => LensT.of "#{@toString()}.then(#{bc.toString()})", (ma) =>

      # (m c -> m c) -> m a
      modify: (f) =>
        @runM(ma).modify (mb) ->
          bc.runM(mb).modify(f)

      # () -> m c
      get: =>
        @runM(ma).get().chain (b) ->
          bc.run(b).get()
