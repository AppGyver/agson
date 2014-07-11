
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

accept = (predicate) -> traversal (traversable) ->
  modify: (f) ->
    result = f traversable
    if predicate result
      result
    else
      []
  get: ->
    if predicate traversable
      traversable
    else
      []

module.exports = {
  identity
  each
  filter
  accept
}