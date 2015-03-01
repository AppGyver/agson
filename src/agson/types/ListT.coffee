List = require './List'

# m -> ListT m
ListT = (Monad) ->
  # sequence :: [m a] -> m [a]
  sequence = (list) ->
    mas = Monad.of []
    for ma in list.get()
      mas = mas.chain (as) ->
        ma.chain (a) ->
          Monad.of as.concat a
    mas

  # flatten :: [[a]] -> [a]
  flatten = (lists) ->
    result = []
    for list in lists
      result = result.concat list
    result

  class ListTM
    # a -> ListT m a
    @of: (x) -> new ListTM Monad.of List.of x
    of: @of

    # List a -> ListT m a
    @fromList: (list) -> new ListTM Monad.of list

    # [a] -> ListT m a
    @fromArray: (array) -> new ListTM Monad.of List.fromArray array

    # m List a -> ListT m a
    constructor: (@mxs) ->

    # () -> m [a]
    get: -> @mxs.map (xs) -> xs.get()

    # (a -> b) -> ListT m b
    map: (f) ->
      new ListTM @mxs.map (xs) ->
        xs.map f

    # (a -> ListT m b) -> ListT m b
    chain: (f) ->
      # Bind to class scope to get access to fromList, fromArray helpers
      f = f.bind(ListTM)

      mys = @mxs.chain (xs) ->
        myss = xs.map (x) -> f(x).get()
        sequence(myss).chain (yss) ->
          ys = flatten yss
          Monad.of new List ys

      new ListTM mys

module.exports = ListT
