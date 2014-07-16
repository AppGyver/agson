{Just, Nothing} = require 'data.maybe'

lens = require('./Lens').of
{identity} = require './lenses'

# (ma -> boolean) -> Lens a b
where = (predm) -> lens "where(#{predm.toString()})", (ma) ->
  modify: (f) ->
    unless predm(ma)
      ma
    else
      f ma
  get: ->
    unless predm(ma)
      Nothing()
    else
      ma

# (() -> Lens a b) -> Lens a b
recurse = (lensf) -> lens "recurse(...)", (ma) ->
  end =
    modify: (f) -> f ma
    get: -> ma

  unless ma.isJust
    end
  else
    store = lensf().runM(ma)
    next = store.get()

    unless next.isJust
      end
    else
      modify: (f) ->
        store.modify f
      get: ->
        next

product = do ->
  tupleAsString = (list) -> (abl.toString() for abl in list).join ','
  dictAsString = (object) -> ("#{key}:#{abl.toString()}" for key, abl of object).join ','

  tuple: (list) -> lens "product.tuple[#{tupleAsString list}]", (ma) ->
    get: ->
      tuple = Just []
      for abl in list
        tuple = tuple.chain (t) ->
          abl.runM(ma).get().chain (b) ->
            t.push b
            Just t
      tuple

  dict: (object) -> lens "product.dict{#{dictAsString object}}", (ma) ->

module.exports = {
  where
  recurse
  product
}