{Just, Nothing} = require 'data.maybe'
{maybeMap, maybeMapValues} = require './util'

Traversal = require './Traversal'
traversal = Traversal.of

nothing =
  modify: -> Nothing()
  get: -> Nothing()

# Traverse array values through a lens
array = (lens) -> traversal (array) ->
  unless array instanceof Array
    nothing
  else
    modify: (f) ->
      Just maybeMap array, (a) ->
        lens.run(a).modify(f).orElse ->
          Just a
    get: ->
      Just maybeMap array, (a) ->
        lens.run(a).get()

module.exports = {
  array
}