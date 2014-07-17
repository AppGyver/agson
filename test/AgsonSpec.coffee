{Just, Nothing} = require 'data.maybe'
Validation = require 'data.validation'

require('chai').should()

agson = require('../src/agson')

describe 'agson query', ->
  describe 'running', ->
    it 'can be done via map', ->
      agson
        .map((v) -> v + 1)
        .run(1)
        .should.deep.equal Just 2

    it 'can be done via get', ->
      agson
        .get()
        .run(1)
        .should.deep.equal Just 1

    it 'can be done via set', ->
      agson
        .set('foo')
        .run('bar')
        .should.deep.equal Just 'foo'

  describe 'composing different lenses together', ->
    it 'can compose list, property and object', ->
      agson
        .list()
        .property('foo')
        .object()
        .map((v) -> v + 1)
        .run([
          { foo: bar: 1 }
          { foo: qux: 2 }
          { foo: baz: 3 }
        ])
        .should.deep.equal Just [
          { foo: bar: 2 }
          { foo: qux: 3 }
          { foo: baz: 4 }
        ]

    it 'can compose list and recurse', ->
      agson
        .list()
        .recurse()
        .where((v) -> typeof v is 'number')
        .map((v) -> v + 1)
        .run([
          1
          [2]
          [[3]]
          [[[4]]]
        ])
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
        .map((foo) -> foo + 111)
        .run([
          { foo: 123 }
          { foo: 456, here: true }
        ])
        .should.deep.equal Just [
          { foo: 123 }
          { foo: 567, here: true }
        ]

  describe 'chaining', ->
    it 'can do partial recursion by chaining multiple queries', ->
      agson
        .list()
        .then(
          agson.property('foo').recurse()
        )
        .where((v) -> typeof v is 'number')
        .map((foo) -> foo + 1)
        .run([
          { foo: 1 }
          { foo: foo: 2 }
          { foo: foo: foo: 3 }
        ])
        .should.deep.equal Just [
          { foo: 2 }
          { foo: foo: 3 }
          { foo: foo: foo: 4 }
        ]

  describe 'selectMany', ->
    it 'is an alias for property().list()', ->
      agson
        .selectMany('foos')
        .map((v) -> v + 1)
        .run({
          foos: [1, 2, 3]
        })
        .should.deep.equal Just foos: [2, 3, 4]

  describe 'validateAs', ->
    string = (input) ->
      if typeof input is 'string'
        Validation.Success input
      else
        Validation.Failure ['not a string']

    it 'composes a fromValidator given a type', ->
      agson
        .validateAs(string)
        .get()
        .run('string')
        .should.deep.equal Just 'string'

      agson
        .validateAs(string)
        .get()
        .run(123)
        .should.deep.equal Nothing()

