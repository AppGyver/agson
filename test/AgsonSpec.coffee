{Just} = require 'data.maybe'
require('chai').should()

agson = require('../src/agson')

describe 'agson query', ->
  describe 'composing different lenses together', ->
    it 'can compose list, property and object', ->
      agson
        .list()
        .property('foo')
        .object()
        .run([
          { foo: bar: 1 }
          { foo: qux: 2 }
          { foo: baz: 3 }
        ])
        .map((v) -> v + 1)
        .should.deep.equal Just [
          { foo: bar: 2 }
          { foo: qux: 3 }
          { foo: baz: 4 }
        ]

    it 'can compose list and recurse', ->
      agson
        .list()
        .recurse()
        .run([
          1
          [2]
          [[3]]
          [[[4]]]
        ])
        .map((v) -> v + 1)
        .should.deep.equal Just [
          2
          [3]
          [[4]]
          [[[5]]]
        ]

    it 'can compose list and where', ->
      agson
        .list()
        .where((v) -> v.here)
        .property('foo')
        .run([
          { foo: 123 }
          { foo: 456, here: true }
        ])
        .map((foo) -> foo + 111)
        .should.deep.equal Just [
          { foo: 123 }
          { foo: 567, here: true }
        ]
