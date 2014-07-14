Maybe = require 'data.maybe'
{notImplemented, maybeFlatmap} = require './util'
Store = require './Store'
Lens = require './Lens'

# Traversable a => Traversal a b
module.exports = class Traversal extends Lens

  # (a -> { get, modify }) -> Traversal a b
  @of: (description ,fs) ->
    new class extends Traversal
      runM: (mt) -> Store.of(Maybe)(fs mt)
      toString: -> description

  then: (bc) => Traversal.of "#{@toString()}.then(#{bc.toString()})", (ma) =>

    modify: (f) =>
      @runM(ma).modify (mb) ->
        bc.runM(mb).modify f

    get: =>
      @runM(ma).get().map (bs) ->
        maybeFlatmap bs, (b) ->
          mb = Maybe.fromNullable b
          bc.runM(mb).get().orElse -> mb
