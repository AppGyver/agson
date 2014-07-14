{Just} = require 'data.maybe'

require('chai').should()
traversals = require '../../src/agson/traversals'
lenses = require '../../src/agson/lenses'
laws = require './laws'

describe 'agson.traversals', ->

  {identity, property} = lenses

  describe 'list', ->
    {list} = traversals

    it 'is the identity for lists', ->
      list
        .run(['foo', 'bar'])
        .get()
        .should.deep.equal Just ['foo', 'bar']

    it 'sets each value in a list', ->
      list
        .run(['foo', 'bar'])
        .set('baz')
        .should.deep.equal Just ['baz', 'baz']

    it 'maps over the list', ->
      list
        .run(['foo', 'bar'])
        .map((v) -> v + 'qux')
        .should.deep.equal Just ['fooqux', 'barqux']

    describe 'composition', ->

      laws.associativity(
        list
        property 'foo'
        list
      ) {
        run: [
          { foo: [ 1, 2, 3 ] }
          { foo: [ 4, 5, 6 ] }
        ]
        map: (v) -> v + 1
        set: 'qux'
      }

      describe 'map', ->
        it 'flattens Maybe List Maybe List into Maybe List List', ->
          list
            .then(list)
            .run([['foo', 'bar']])
            .map((v) -> v + 'qux')
            .should.deep.equal Just [ ['fooqux', 'barqux'] ]

      describe 'get', ->
        it 'can flatten List List into List', ->
          list
            .then(list)
            .run([['foo', 'bar']])
            .get()
            .should.deep.equal Just ['foo', 'bar']

        it 'works with nested lists and objects', ->
          list
            .then(property 'foo')
            .run([{ foo: 'bar'}, { foo: 'qux' }])
            .get()
            .should.deep.equal Just ['bar', 'qux']

          property('foo')
            .then(list)
            .run({foo: [ 1, 2, 3 ]})
            .get()
            .should.deep.equal Just [ 1, 2, 3 ]

  describe 'object', ->
    {object} = traversals

    describe 'composition', ->
      laws.associativity(
        object
        property 'foo'
        object
      ) {
        run: {
          a: { foo: { bar: 123, qux: 678 } }
          b: { foo: { bar: 456 } }
        }
        map: (v) -> 111 + v
      }
