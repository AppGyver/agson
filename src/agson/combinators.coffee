{Just, Nothing} = require 'data.maybe'

lens = require('./Lens').of
{identity} = require './lenses'

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

module.exports = {
  accept
  definedAt
  where
  recurse
}