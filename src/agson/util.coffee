module.exports =
  notImplemented: -> throw new Error 'not implemented'

  maybeMap: (xs, f) ->
    ys = []
    for x in xs
      maybeY = f x
      if maybeY.isJust
        ys.push maybeY.get()
    ys

  maybeFlatmap: (array, f) ->
    result = []
    for value in array
      maybeA = f value
      if maybeA.isJust
        result = result.concat maybeA.get()
    result