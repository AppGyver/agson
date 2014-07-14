{Just, Nothing} = require 'data.maybe'

lens = require('./Lens').of

# (a -> boolean) -> Lens a a
accept = (predicate) -> lens "predicate(#{predicate.toString()})", (ma) ->
  modify: (f) ->
    f(ma).chain (b) ->
      if predicate b
        Just b
      else
        Nothing()

  get: ->
    ma.chain (a) ->
      if predicate a
        Just a
      else
        Nothing()

# Lens a b -> (ma -> boolean)
definedAt = (abl) -> (ma) ->
  abl.runM(ma).get().isJust

# (ma -> boolean) -> Lens a b
where = (predm) -> lens "where(#{predm.toString()})", (ma) ->
  modify: (f) ->
    unless predm(ma)
      Nothing()
    else
      f ma
  get: ->
    unless predm(ma)
      Nothing()
    else
      ma

module.exports = {
  accept
  definedAt
  where
}