
Traversal = require './Traversal'
traversal = Traversal.of

identity = traversal (traversable) ->
  modify: (f) ->
    f traversable
  get: ->
    traversable

each = traversal (traversable) ->
  modify: (f) ->
    f a for a in traversable
  get: ->
    traversable

filter = (predicate) -> traversal (traversable) ->
  modify: (f) ->
    f a for a in traversable when predicate a
  get: ->
    a for a in traversable when predicate a

module.exports = {
  identity
  each
  filter
}