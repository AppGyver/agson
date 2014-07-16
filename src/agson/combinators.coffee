{Just, Nothing, fromNullable} = require 'data.maybe'

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

    modify: (f) ->
      f(@get()).chain (tuple) ->
        result = ma
        for abl in list
          result = abl.runM(result).set(tuple.shift())
        result

  dict: (object) -> lens "product.dict{#{dictAsString object}}", (ma) ->
    get: ->
      dict = Just {}
      for key, abl of object
        dict = dict.chain (d) ->
          abl.runM(ma).get().chain (b) ->
            d[key] = b
            Just d
      dict

    modify: (f) ->
      f(@get()).chain (dict) ->
        result = ma
        for key, abl of object
          mb = fromNullable dict[key]
          result = abl.runM(result).modify -> mb
        result

module.exports = {
  where
  recurse
  product
}