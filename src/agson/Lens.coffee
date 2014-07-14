Maybe = require 'data.maybe'
{notImplemented} = require './util'
Store = require('./Store')

# Lens a b
module.exports = class Lens

  # (a -> { get, modify }) -> Lens a b
  @of: (description, fs) ->
    new class extends Lens
      run: (a) -> Store.of(Maybe)(fs a)
      toString: -> description

  # a -> Store Maybe b
  run: notImplemented

  # Lens b c -> Lens a c
  then: (bc) => Lens.of "#{@toString()}.then(#{bc.toString()})", (a) =>

    # (Maybe c -> Maybe c) -> Maybe a
    modify: (f) =>
      @run(a).modify (mb) ->
        mb.chain (b) ->
          bc.run(b).modify(f)

    # () -> Maybe c
    get: =>
      @run(a).get().chain (b) ->
        bc.run(b).get()
