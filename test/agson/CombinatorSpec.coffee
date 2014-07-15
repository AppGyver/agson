{Just, Nothing} = require 'data.maybe'
require('chai').should()
lenses = require '../../src/agson/lenses'
traversals = require '../../src/agson/traversals'
combinators = require '../../src/agson/combinators'

laws = require './laws'

describe 'agson.combinators', ->
  {identity} = lenses

  describe 'where', ->
    {property} = lenses
    {where} = combinators
    whereHasFoo = where (ma) ->
      ma.map((a) -> a.foo?).getOrElse false

    describe 'get', ->
      it 'is identity if condition matches', ->
        whereHasFoo.run(foo: 'bar').get().should.deep.equal Just foo: 'bar'
        whereHasFoo.run(qux: 'bar').get().should.deep.equal Nothing()
        whereHasFoo.run('bar').get().should.deep.equal Nothing()

    describe 'modify', ->
      it 'is constant if condition does not match', ->
        whereHasFoo.run(foo: 'bar').set('qux').should.deep.equal Just 'qux'
        whereHasFoo.run('bar').set('qux').should.deep.equal Just 'bar'

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

