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

  describe 'product', ->
    {product} = combinators
    {property} = lenses

    describe 'tuple', ->
      describe 'get', ->
        it 'is a list of something than can be broken down according to lenses in a list', ->
          product.tuple([
            property('foo')
            property('bar')
          ]).run({
            foo: 1
            bar: 2
          })
          .get()
          .should.deep.equal Just [1, 2]

      describe 'modify', ->
        it 'modifies each piece in turn but retains the original structure in the output', ->
          product.tuple([
            property('foo')
            property('bar')
          ]).run({
            foo: 1
            bar: 2
          })
          .map(([foo, bar]) -> ['qux', 'baz'])
          .should.deep.equal Just {
            foo: 'qux'
            bar: 'baz'
          }

    describe 'dict', ->
      describe 'get', ->
        it 'is an object of something that can be broken down according to lenses in values', ->
          product.dict({
            one: property 'foo'
            two: property 'bar'
          })
          .run({
            foo: 1
            bar: 2
          })
          .get()
          .should.deep.equal Just {
            one: 1
            two: 2
          }

        it 'modifies each value in turn but retains the original structure in the output', ->
          product.dict({
            one: property 'foo'
            two: property 'bar'
          })
          .run({
            foo: 1
            bar: 2
          })
          .map(({one, two}) -> { one: 'qux', two: 'baz'})
          .should.deep.equal Just {
            foo: 'qux'
            bar: 'baz'
          }


    describe 'recursing down a cons list', ->
      {recurse} = traversals
      
      List =
        Cons: (head, tail) -> {head, tail}
        Nil: {}

      list = null
      before ->
        list = product.dict(
          head: property('head')
          tail: property('tail')
        ).then recurse -> property('tail').then list

      it 'yields tuple with structure similar to input lens list on get', ->
        list
          .run(
            List.Nil
          )
          .get()
          .should.deep.equal Nothing()

        list
          .run(
            List.Cons 1, List.Nil
          )
          .get()
          .should.deep.equal Just [
            List.Cons 1, List.Nil
          ]

        list
          .run(
            List.Cons 1, List.Cons 2, List.Nil
          )
          .get()
          .should.deep.equal Just [
            List.Cons 2, List.Nil
            List.Cons 1, List.Cons 2, List.Nil
          ]

      it 'preserves structure on modify', ->
        list.run(
          List.Cons 1, List.Cons 2, List.Cons 3, List.Nil
        )
        .map(({head, tail}) -> List.Cons (head + 1), tail)
        .should.deep.equal Just List.Cons 2, List.Cons 3, List.Cons 4, List.Nil

  describe.skip 'sum', ->
    {sum, where} = combinators
    {list, object, recurse} = traversals

    describe 'recursing down a sum type', ->
      graph = null
      before ->
        graph = sum(list, object).then recurse -> graph

      it 'yields identity on get', ->
        graph
          .run([1, { foo: 2 }, [ 3, { bar: 4 } ] ])
          .get()
          .should.deep.equal Just [1, { foo: 2 }, [ 3, { bar: 4 } ] ]

      it 'preserves structure on modify', ->
        graph
          .run([1, { foo: 2 }, [ 3, { bar: 4 } ] ])
          .map((v) -> v + 1)
          .should.deep.equal Just [2, { foo: 3 }, [ 4, { bar: 5 } ] ]

