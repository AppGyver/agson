List = require '../../../src/agson/types/List'
ListT = require '../../../src/agson/types/ListT'
Maybe = require 'data.maybe'
{Just, Nothing} = Maybe

require('chai').should()

describe 'agson.types.ListT', ->

  ListTMaybe = ListT Maybe

  describe 'of', ->
    it 'wraps the List constructor with the outer Monad constructor', ->
      ListTMaybe.of('foo').get().should.deep.equal Just ['foo']

  describe 'fromList', ->
    it 'wraps a List with the outer Monad constructor', ->
      ListTMaybe.fromList(List.of 'foo').get().should.deep.equal Just ['foo']

  describe 'map', ->
    it 'maps any values in the inner List', ->
      ListTMaybe.fromList(List.empty()).map((f) -> throw new Error).get().should.deep.equal Just []
      ListTMaybe.fromList(List.of 'foo').map((f) -> f + 'bar').get().should.deep.equal Just ['foobar']

  describe 'chain', ->
    it 'flatmaps a maybe-list-generating function', ->
      ListTMaybe.fromList(List.of 1)
        .chain((n) ->
          @fromArray [n + 1, n + 2, n+ 3]
        )
        .get()
        .should.deep.equal Just [2, 3, 4]