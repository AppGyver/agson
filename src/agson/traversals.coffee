{Just, Nothing} = require 'data.maybe'
{maybeMap, maybeMapValues} = require './util'

Traversal = require './Traversal'
traversal = Traversal.of

nothing =
  modify: -> Nothing()
  get: -> Nothing()

list = traversal (traversable) ->
  unless traversable instanceof Array
    nothing
  else
    modify: (f) ->
      Just (f a for a in traversable)
    get: ->
      Just traversable


object = traversal (object) ->
  unless typeof object is 'object'
    nothing
  else
    modify: (f) ->
      Just (
        result = {}
        for key, value of object
          result[key] = f value
        result
      )
    get: ->
      Just (value for key, value of object)

module.exports = {
  list
  object
}