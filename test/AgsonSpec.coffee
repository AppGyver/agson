{Just} = require 'data.maybe'
require('chai').should()

agson = require('../src/agson')

describe 'agson query', ->
  it 'can compose predefined lenses together', ->
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
