List = require '../../../src/agson/types/List'
Maybe = require 'data.maybe'

require('chai').should()

describe 'agson.types.List', ->
  describe 'of', ->
    it 'constructs a List of one element', ->
      List.of('foo').get().should.deep.equal ['foo']

  describe 'fromArray', ->
    it 'constructs a List from an existing array of elements', ->
      List.fromArray(['foo', 'bar']).get().should.deep.equal ['foo', 'bar']

  describe 'fromMaybe', ->
    it 'constructs a List with either one or zero elements', ->
      List.fromMaybe(Maybe.Just 'foo').get().should.deep.equal ['foo']
      List.fromMaybe(Maybe.Nothing()).get().should.deep.equal []

  describe 'empty', ->
    it 'constructs an empty List', ->
      List.empty().get().should.deep.equal []

  describe 'concat', ->
    it 'joins elements from two Lists', ->
      List.empty().concat(List.of 'foo').get().should.deep.equal ['foo']
      List.of('foo').concat(List.empty()).get().should.deep.equal ['foo']

  describe 'map', ->
    it 'creates a new List with elements mapped', ->
      List.empty().map((f) -> throw new Error).get().should.deep.equal []
      List.of('foo').map((f) -> f + 'bar').get().should.deep.equal ['foobar']
      List.fromArray([1, 2, 3]).map((f) -> f + 1).get().should.deep.equal [2, 3, 4]

  describe 'chain', ->
    it 'flattens Lists from a List-creating function', ->
      List.empty().chain((f) -> throw new Error).get().should.deep.equal []
      List.of(1).chain((f) -> List.fromArray [f+1, f+2, f+3]).get().should.deep.equal [2, 3, 4]

