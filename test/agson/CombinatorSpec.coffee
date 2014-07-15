{Just, Nothing} = require 'data.maybe'
require('chai').should()
lenses = require '../../src/agson/lenses'
traversals = require '../../src/agson/traversals'
combinators = require '../../src/agson/combinators'

laws = require './laws'

describe 'agson.combinators', ->
  {identity} = lenses

  describe 'accept', ->
    {accept} = combinators
    strings = accept (a) -> typeof a is 'string'

    it 'can decide whether getting a provided lens will succeed', ->
      strings.run('foo').get().should.deep.equal Just 'foo'
      strings.run(123).get().should.deep.equal Nothing()

    it 'can decide whether setting a provided lens will succeed', ->
      strings.run(123).set('foo').should.deep.equal Just 'foo'
      strings.run('foo').set(123).should.deep.equal Nothing()

    describe 'composition', ->
      laws.identity(identity)(strings) {
        runAll: [
          'foo'
          123
        ]
        map: (v) -> v + 'bar'
      }


  describe 'definedAt', ->
    {property} = lenses
    {definedAt} = combinators
    withFoo = definedAt property 'foo'

    it 'will succeed if getting succeeds', ->
      withFoo(Just { foo: 'bar' }).should.be.true
      withFoo(Just { qux: 'bar' }).should.be.false


  describe 'where', ->
    {property} = lenses
    {where, definedAt} = combinators
    whereHasFoo = where definedAt property 'foo'

    it 'is identity if condition matches', ->
      whereHasFoo.run(foo: 'bar').get().should.deep.equal Just foo: 'bar'
      whereHasFoo.run(qux: 'bar').get().should.deep.equal Nothing()
      whereHasFoo.run(foo: 'bar').set('qux').should.deep.equal Just 'qux'

    it 'is nothing if condition does not match', ->
      whereHasFoo.run('bar').get().should.deep.equal Nothing()
      whereHasFoo.run('bar').set('qux').should.deep.equal Nothing()

    describe 'composition', ->
      laws.identity(identity)(whereHasFoo) {
        runAll: [
          { foo: 123 }
          {}
        ]
        map: (v) -> v + 111
      }

      {list} = traversals
      laws.associativity(
        list
        whereHasFoo
        property 'bar'
      ) {
        run: [
          { foo: 'anything', bar: 123 }
          { bar: 'baz' }
        ],
        map: (v) -> v + 123
      }

  describe 'recurse', ->
    {property} = lenses
    {list} = traversals
    {recurse} = combinators
    it 'allows self-recursion via lazy binding', ->
      foo = property('foo').then recurse -> foo
      foo
        .run(foo: foo: foo: foo: 123)
        .map((v) -> v + 111)
        .should.deep.equal Just foo: foo: foo: foo: 234

      lists = list.then recurse -> lists
      lists
        .run([1, [2, [3]]])
        .map((v) -> v + 1)
        .should.deep.equal Just [2, [3, [4]]]

