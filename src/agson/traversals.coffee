Maybe = require 'data.maybe'
{Just, Nothing, fromNullable} = Maybe
{maybeMap, maybeMapValues, isArray, isObject} = require './util'

Traversal = require './types/Traversal'
traversal = Traversal.of

List = require './types/List'

nothing =
  modify: Nothing
  get: Nothing

list = traversal "list", (ta) ->
  modify: (f) -> ta.chain f
  get: -> ta

object =
  values:
    traversal "object.values", (mo) ->
      modify: (f) ->
        mo.map (object) ->
          unless isObject object
            Nothing()
          else
            maybeMapValues object, (value) ->
              f fromNullable value
      get: ->
        mo.chain (object) ->
          unless isObject object
            Nothing()
          else
            Just [value for key, value of object]

# (() -> Lens a b) -> Lens a b
recurse = (lensf) -> traversal "recurse(...)", (ma) ->
  abl = lensf()
  
  modify: (f) ->
    ma.chain (a) ->
      storeb = abl.runM(ma)
      mb = storeb.get()
      if mb.isNothing
        f ma
      else
        f storeb.modify f

  get: ->
    ma.chain (a) ->
      abl
        .runM(ma)
        .get()
        .map((bs) -> bs.concat [a])
        .orElse -> Just [a]

module.exports = {
  list
  object
  recurse
}