Maybe = require 'data.maybe'
{maybeMap} = require '../util'
Store = require './Store'
Lens = require './Lens'

# Traversable a => Traversal a b
module.exports = class Traversal extends Lens

  # (a -> { get, modify }) -> Traversal a b
  @of: (description ,fs) ->
    new class extends Traversal
      runM: (mt) -> Store(Maybe).of(fs mt)
      toString: -> description

  then: (bc) => Traversal.of "#{@toString()}.then(#{bc.toString()})", (ma) =>

    modify: (f) =>
      @runM(ma).modify (mb) ->
        bc.runM(mb).modify f

    get: =>
      @runM(ma).get().map((bs) ->
        maybeMap bs, (b) ->
          bc.run(b).get()
      )
