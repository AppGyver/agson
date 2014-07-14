{Just, Nothing} = require 'data.maybe'
{maybeMap, maybeMapValues} = require './util'

Traversal = require './Traversal'
traversal = Traversal.of

nothing =
  modify: Nothing
  get: Nothing

list = traversal "list", (traversable) ->
  unless traversable instanceof Array
    nothing
  else
    modify: (f) ->
      Just maybeMap traversable, (a) ->
        f Just a
    get: ->
      Just traversable


object = traversal "object", (object) ->
  unless typeof object is 'object'
    nothing
  else
    modify: (f) ->
      Just (
        maybeMapValues object, (value) ->
          f Just value
      )
    get: ->
      Just (value for key, value of object)

module.exports = {
  list
  object
}