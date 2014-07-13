{Just, Nothing} = require 'data.maybe'
{maybeMap, maybeMapValues} = require './util'

Traversal = require './Traversal'
traversal = Traversal.of

nothing =
  modify: -> Nothing()
  get: -> Nothing()

array = traversal (array) ->
  unless array instanceof Array
    nothing
  else
    modify: (f) ->
      Just (f a for a in array)
    get: ->
      Just array

module.exports = {
  array
}