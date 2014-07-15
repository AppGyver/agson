lenses = require './agson/lenses'
traversals = require './agson/traversals'
combinators = require './agson/combinators'

liftL = (lensf) -> (args...) ->
  new AgsonQuery @lens.then lensf args...

class AgsonQuery

  constructor: (@lens) ->
  toString: ->
    "agson(#{@lens.toString()})"

  list: liftL -> traversals.list
  object: liftL -> traversals.object
  property: liftL lenses.property
  recurse: ->
    lens = @lens.then combinators.recurse -> lens
    new AgsonQuery lens

  run: (data) -> @lens.run data

module.exports = new AgsonQuery
  then: (lens) -> lens
