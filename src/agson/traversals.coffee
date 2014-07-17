{Just, Nothing, fromNullable} = require 'data.maybe'
{maybeMap, maybeMapValues, isArray, isObject} = require './util'

Traversal = require './Traversal'
traversal = Traversal.of

nothing =
  modify: Nothing
  get: Nothing

list = traversal "list", (mta) ->
  modify: (f) ->
    mta.chain (ta) ->
      unless isArray ta
        Nothing()
      else
        Just maybeMap ta, (a) ->
          f fromNullable a

  get: ->
    mta.chain (ta) ->
      unless isArray ta
        Nothing()
      else
        Just ta


object = traversal "object", (mo) ->
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
        Just object

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