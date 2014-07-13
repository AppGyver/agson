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

module.exports = {
  list
}