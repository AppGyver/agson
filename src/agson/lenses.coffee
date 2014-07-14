merge = require 'lodash-node/modern/objects/merge'
{Just, Nothing, fromNullable} = require 'data.maybe'

lens = require('./Lens').of

nothing = lens "nothing", ->
  modify: Nothing
  get: Nothing

identity = lens "identity", (ma) ->
  modify: (f) -> f ma
  get: -> ma

constant = (value) -> lens "constant(#{value})", ->
  modify: -> fromNullable value
  get: -> fromNullable value

property = (key) -> lens "property(#{key})", (mo) ->
  modify: (f) ->
    mo.chain (object) ->
      mv = fromNullable(object[key])
      f(mv).chain (value) ->
        modification = {}
        modification[key] = value
        Just merge {}, object, modification
  get: ->
    mo.chain (object) ->
      fromNullable object[key]

module.exports = {
  nothing
  identity
  constant
  property
}