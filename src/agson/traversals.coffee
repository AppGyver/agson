Maybe = require 'data.maybe'
{maybeMap} = require './util'

Traversal = require './Traversal'
traversal = Traversal.of

identity = traversal (traversable) ->
  modify: (f) ->
    f traversable
  get: ->
    traversable

each = (lens) -> traversal (traversable) ->
  modify: (f) ->
    maybeMap traversable, (a) ->
      lens.run(a).modify(f).orElse ->
        Maybe.Just a
  get: ->
    maybeMap traversable, (a) ->
      lens.run(a).get()

where = (predicate) -> traversal (traversable) ->
  modify: (f) ->
    for a in traversable
      if predicate a
        f a
      else
        a
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
  where
  accept
}