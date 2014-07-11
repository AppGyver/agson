
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

where = (predicate) -> traversal (traversable) ->
  modify: (f) ->
    for a in traversable
      if predicate a
        f a
      else
        a
  get: ->
    traversable

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
  where
  accept
}