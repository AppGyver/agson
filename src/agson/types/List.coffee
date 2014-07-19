
module.exports = class List
  @of: (x) ->
    new List [x]

  of: @of

  @fromArray: (a) ->
    if a instanceof Array
      new List a
    else
      new List []

  @fromMaybe: (ma) ->
    new List (
      ma.map((a) -> [a]).getOrElse []
    )

  @empty: ->
    new List []

  empty: @empty

  concat: (list) ->
    new List (@xs.concat list.get())

  constructor: (@xs) ->

  map: (f) ->
    new List (f x for x in @xs)

  chain: (f) ->
    result = []
    for x in @xs
      result = result.concat f(x).get()
    new List result

  get: ->
    @xs
