{Just} = require 'data.maybe'

require('chai').should()
traversals = require '../../src/agson/traversals'
lenses = require '../../src/agson/lenses'
laws = require './laws'

describe 'agson.traversals', ->

  {identity, property} = lenses

  describe 'array', ->
    {array} = traversals

    it 'runs each value in an array through a lens', ->
      array
        .run(['foo', 'bar'])
        .get()
        .should.deep.equal Just ['foo', 'bar']

      array
        .run(['foo', 'bar'])
        .set('baz')
        .should.deep.equal Just ['baz', 'baz']

      array
        .run(['foo', 'bar'])
        .modify((v) -> v + 'qux')
        .should.deep.equal Just ['fooqux', 'barqux']

    describe 'composition', ->
      describe 'modify', ->
        it 'flattens Maybe List Maybe List into Maybe List List', ->
          array
            .then(array)
            .run([['foo', 'bar']])
            .modify((v) -> v + 'qux')
            .should.deep.equal Just [ ['fooqux', 'barqux'] ]

      describe 'get', ->
        it 'can flatten List List into List', ->
          array
            .then(array)
            .run([['foo', 'bar']])
            .get()
            .should.deep.equal Just ['foo', 'bar']

        it 'works with nested arrays and objects', ->
          array
            .then(property 'foo')
            .run([{ foo: 'bar'}, { foo: 'qux' }])
            .get()
            .should.deep.equal Just ['bar', 'qux']

          property('foo')
            .then(array)
            .run({foo: [ 1, 2, 3 ]})
            .get()
            .should.deep.equal Just [ 1, 2, 3 ]

        it 'composes inside out', ->
          array.then(property('foo').then(array))
            .run([
              { foo: [ 1, 2, 3 ] }
              { foo: [ 4, 5, 6 ] }
            ])
            .get()
            .should.deep.equal Just [1, 2, 3, 4, 5, 6]

      describe 'modify', ->
        it 'composes outside in', ->
          array.then(property('foo')).then(array)
            .run([
              { foo: [ 1, 2, 3 ] }
              { foo: [ 4, 5, 6 ] }
            ])
            .modify((v) -> v + 1)
            .should.deep.equal Just [
              { foo: [ 2, 3, 4 ] }
              { foo: [ 5, 6, 7 ] }
            ]

