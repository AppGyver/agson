{notImplemented} = require '../util'
Store = require('./Store')

# (Monad m, Any -> m a) => LensT m a b = a -> StoreT m a b
module.exports = (Monad) ->
  class LensT
    Store: Store(Monad)

    constructor: ({@run, @toString}) ->

    # (a -> { get, set }) -> LensT m a b
    @of: (description, fs) ->
      new LensT(
        run: (a) -> @Store.of(fs a)
        toString: -> description
      )

    # a -> StoreT m a b
    run: notImplemented("run")

    # LensT m b c -> LensT m a c
    then: (bc) => LensT.of "#{@toString()}.then(#{bc.toString()})", (a) =>

      # m c -> m a
      set: (mc) =>
        abs = @run(a)
        abs.get().chain (b) ->
          bcs = bc.run(b)
          abs.set bcs.set(mc)

      # () -> m c
      get: =>
        @run(a).get().chain (b) ->
          bc.run(b).get()
