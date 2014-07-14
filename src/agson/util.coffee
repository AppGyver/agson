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
    for value, index in array
      maybeA = f value
      if maybeA.isJust
        result = result.concat maybeA.get()
    result

  maybeMapValues: (object, f) ->
    result = {}
    for key, value of object
      maybeV = f value
      if maybeV.isJust
        result[key] = maybeV.get()
    result
