{Just} = require 'data.maybe'

require('chai').should()
traversals = require '../../src/agson/traversals'
lenses = require '../../src/agson/lenses'
laws = require './laws'

describe 'agson.traversals', ->

  {identity, property} = lenses

  describe 'array', ->
    {array} = traversals

    arrayValues = array identity
    it 'runs each value in an array through a lens', ->
      arrayValues
        .run(['foo', 'bar'])
        .get()
        .should.deep.equal Just ['foo', 'bar']

      arrayValues
        .run(['foo', 'bar'])
        .set('baz')
        .should.deep.equal Just ['baz', 'baz']

      arrayValues
        .run(['foo', 'bar'])
        .modify((v) -> v + 'qux')
        .should.deep.equal Just ['fooqux', 'barqux']

    describe 'composition', ->
      describe 'modify', ->
        it 'flattens Maybe List Maybe List into Maybe List List', ->
          arrayValues
            .then(arrayValues)
            .run([['foo', 'bar']])
            .modify((v) -> v + 'qux')
            .should.deep.equal Just [ ['fooqux', 'barqux'] ]

      describe 'get', ->
        it 'can flatten List List into List', ->
          arrayValues
            .then(arrayValues)
            .run([['foo', 'bar']])
            .get()
            .should.deep.equal Just ['foo', 'bar']

        it 'works with nested arrays and objects', ->
          arrayValues
            .then(property 'foo')
            .run([{ foo: 'bar'}, { foo: 'qux' }])
            .get()
            .should.deep.equal Just ['bar', 'qux']

          property('foo')
            .then(arrayValues)
            .run({foo: [ 1, 2, 3 ]})
            .get()
            .should.deep.equal Just [ 1, 2, 3 ]

        it 'can be composed ad nauseam', ->
          arrayValues.then(property('foo').then(arrayValues))
            .run([
              { foo: [ 1, 2, 3 ] }
              { foo: [ 4, 5, 6 ] }
            ])
            .get()
            .should.deep.equal Just [1, 2, 3, 4, 5, 6]

