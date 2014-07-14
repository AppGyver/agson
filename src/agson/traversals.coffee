{Just, Nothing, fromNullable} = require 'data.maybe'
{maybeMap, maybeMapValues} = require './util'

Traversal = require './Traversal'
traversal = Traversal.of

nothing =
  modify: Nothing
  get: Nothing

list = traversal "list", (mta) ->
  modify: (f) ->
    mta.chain (ta) ->
      unless ta instanceof Array
        Nothing()
      else
        Just maybeMap ta, (a) ->
          f fromNullable a

  get: ->
    mta


object = traversal "object", (mo) ->
  modify: (f) ->
    mo.map (object) ->
      maybeMapValues object, (value) ->
        f fromNullable value
  get: ->
    mo.chain (object) ->
      Just (value for own key, value of object)

module.exports = {
  list
  object
}