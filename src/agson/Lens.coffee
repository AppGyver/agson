Maybe = require 'data.maybe'
{notImplemented} = require './util'
Store = require('./Store')

# Lens a b
module.exports = class Lens

  # (Maybe a -> { get, modify }) -> Lens a b
  @of: (description, fs) ->
    new class extends Lens
      runM: (ma) -> Store.of(Maybe)(fs ma)
      toString: -> description

  # Maybe a -> Store Maybe b
  runM: notImplemented

  # a -> Store Maybe b
  run: (a) -> @runM Maybe.fromNullable a

  # Lens b c -> Lens a c
  then: (bc) => Lens.of "#{@toString()}.then(#{bc.toString()})", (ma) =>

    # (Maybe c -> Maybe c) -> Maybe a
    modify: (f) =>
      @runM(ma).modify (mb) ->
        bc.runM(mb).modify(f)

    # () -> Maybe c
    get: =>
      bc.runM(@runM(ma).get()).get()
