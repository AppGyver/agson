module.exports =
  notImplemented: -> throw new Error 'not implemented'

  maybeMap: (xs, f) ->
    ys = []
    for x in xs
      maybeY = f x
      if maybeY.isJust
        ys.push maybeY.get()
    ys

  maybeMapValues: (object, f) ->
    result = {}
    for own key, value of object
      maybeV = f value
      if maybeV.isJust
        result[key] = maybeV.get()
    result

  isArray: (input) -> (Object::toString.call input) is '[object Array]'
  isObject: (input) -> (Object::toString.call input) is '[object Object]'
