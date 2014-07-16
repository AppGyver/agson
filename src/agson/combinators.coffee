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
  abl = lensf()
  modify: (f) ->
    bstore = abl.runM(ma)
    mb = bstore.get()
    if mb.isNothing
      bstore.modify f
    else
      abl.runM(abl.runM(mb).modify(f)).modify(f)
  get: ->
    ma.chain (a) ->
      bstore = abl.runM(ma)
      bstore.get().orElse -> Just [a]


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
          result = result.chain ->
            mb = fromNullable(tuple.shift())
            abl.runM(result).modify -> mb
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
          result = result.chain ->
            mb = fromNullable dict[key]
            abl.runM(result).modify -> mb
        result

module.exports = {
  where
  recurse
  product
}