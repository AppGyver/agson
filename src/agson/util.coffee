module.exports =
  notImplemented: -> throw new Error 'not implemented'

  maybeMap: (xs, f) ->
    ys = []
    for x in xs
      maybeY = f x
      if maybeY.isJust
        ys.push maybeY.get()
    ys