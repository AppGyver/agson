{notImplemented} = require '../util'
Store = require('./Store')

# (Monad m, lift: s -> m s) => LensT m s a b = s -> StoreT m a b
module.exports = (Monad, lift) ->
  class LensT
    Store: Store(Monad)

    constructor: ({@runM, @toString}) ->

    # (description: String, m s -> {
    #  get: () -> m a
    #  modify: (f: (m a) -> (m b)) -> m b
    # }) -> LensT m a b
    @of: (description, fs) ->
      new LensT(
        runM: (a) -> @Store.of(fs a)
        toString: -> description
      )

    # Run the lens on a value
    # s -> StoreT m a b
    run: (s) ->
      @runM lift s

    # m s -> StoreT m a b
    runM: notImplemented


    # Chain this lens on another lens
    # (bc: LensT m b t c) -> LensT m s a c
    then: (bc) => LensT.of "#{@toString()}.then(#{bc.toString()})", (ma) =>

      # (f: m c -> m d) -> m d
      modify: (f) =>
        @runM(ma).modify (mb) ->
          bc.runM(mb).modify(f)

      # () -> m c
      get: =>
        mb = @runM(ma).get()
        bc.runM(mb).get()
