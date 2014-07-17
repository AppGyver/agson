{Just, Nothing, fromNullable, fromValidation} = require 'data.maybe'

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

lensListAsString = (list) -> (abl.toString() for abl in list).join ','
lensMapAsString = (object) -> ("#{key}:#{abl.toString()}" for key, abl of object).join ','

product = do ->

  tuple: (list) -> lens "product.tuple[#{lensListAsString list}]", (ma) ->
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

  dict: (object) -> lens "product.dict{#{lensMapAsString object}}", (ma) ->
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

fromValidator = (validator) -> lens "validate", (ma) ->
  get: ->
    ma.chain (a) ->
      fromValidation validator a

  modify: (f) ->
    ma.chain (a) ->
      validb = fromValidation(validator a)
      if validb.isJust
        f validb
      else
        ma

union = do ->
  withTag = (tag, value) ->
    tagged = {}
    tagged[tag] = value
    Just tagged

  tagged: (tagsToLenses) -> lens "union.tagged(#{lensMapAsString tagsToLenses})", (ma) ->
    get: ->
      result = Nothing()

      for tag, abl of tagsToLenses
        mb = abl.runM(ma).get()
        if mb.isJust
          result = withTag tag, mb.get()
          break
      
      result

    modify: (f) ->
      result = Nothing()

      for tag, abl of tagsToLenses
        tagged = abl.runM(ma).get()
        if tagged.isJust
          result = f withTag tag, tagged.get()
          break

      result

module.exports = {
  where
  product
  fromValidator
  union
}