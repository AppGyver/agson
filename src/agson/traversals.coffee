
Traversal = require './Traversal'
traversal = Traversal.of

identity = traversal (traversable) ->
  modify: (f) ->
    f a for a in traversable
  get: ->
    traversable

module.exports = {
  identity
}