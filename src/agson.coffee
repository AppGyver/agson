lenses = require './agson/lenses'
traversals = require './agson/traversals'
combinators = require './agson/combinators'

liftThen = (lensf) -> (args...) ->
  if @lens is lenses.identity
    new AgsonQuery lensf args...
  else
    new AgsonQuery @lens.then lensf args...

run = (f) -> (args...) ->
  run: (data) =>
    f(@lens.run(data))(args...)


class AgsonQuery

  constructor: (@lens) ->
  toString: ->
    "agson(#{@lens.toString()})"

  then: (query) ->
    new AgsonQuery @lens.then query.lens

  selectMany: (key) ->
    new AgsonQuery @lens.then lenses.property(key).then traversals.list

  list: liftThen -> traversals.list
  object: liftThen -> traversals.object
  property: liftThen lenses.property
  index: liftThen lenses.property

  where: liftThen (predicate) ->
    combinators.where (ma) ->
      ma.map(predicate).getOrElse false

  recurse: ->
    lens = @lens.then traversals.recurse -> lens
    new AgsonQuery lens

  validateAs: (type) ->
    new AgsonQuery @lens.then combinators.fromValidator type

  choose: (options) ->
    tagsToLenses = {}
    for tag, query of options
      tagsToLenses[tag] = query.lens

    new AgsonQuery @lens.then combinators.sum.tagged tagsToLenses

  get: run (s) -> -> s.get()
  set: run (s) -> (v) -> s.set v
  map: run (s) -> (f) -> s.map f

module.exports = new AgsonQuery lenses.identity
