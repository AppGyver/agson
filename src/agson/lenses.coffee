{Just, Nothing} = require 'data.maybe'

lens = (ab) ->
  new class
    run: ab

identity = lens (a) ->
  set: (b) -> Just b
  get: -> Just a

module.exports = {
  identity
}