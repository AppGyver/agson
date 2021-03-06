{Just, Nothing} = require 'data.maybe'
Validation = require 'data.validation'
types = require 'ag-types'

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

  describe 'fromValidator', ->
    {fromValidator} = combinators
    {list} = traversals

    numberValidator = (input) ->
      if typeof input is 'number'
        Validation.Success input
      else
        Validation.Failure ['not a number']

    numberList = list.then(fromValidator numberValidator)

    describe 'get', ->
      it 'gets items through validator', ->
        numberList
          .run([1, 2, 3, 'foo'])
          .get()
          .should.deep.equal Just [ 1, 2, 3 ]

    describe 'modify', ->
      it 'modifies items through validator', ->
        numberList
          .run([1, 2, 3, 'foo'])
          .map((v) -> v + 1)
          .should.deep.equal Just [2, 3, 4, 'foo']

  describe 'sum', ->
    {sum, fromValidator} = combinators

    Leaf =
      of: (value) -> { value }
      type: do ({Object, Any} = types) ->
        Object
          value: Any
    Tree =
      of: (left, right) -> { left, right }
      type: do ({OneOf, Object, Optional, recursive} = types) ->
        OneOf([
          Leaf.type
          Object
            left: Optional recursive -> Tree.type
            right: Optional recursive -> Tree.type
        ])

    describe 'tagged', ->
      tree = null
      before ->
        tree = sum.tagged(
          leaf: fromValidator Leaf.type
          tree: fromValidator Tree.type
        )

      describe 'get', ->
        it 'can read one of the tagged types from root', ->
          tree
            .run(Leaf.of 123)
            .get()
            .should.deep.equal Just leaf: Leaf.of 123

      describe 'modify', ->
        it 'can modify a tagged type at the root', ->
          tree
            .run(Leaf.of 123)
            .map(({tree, leaf}) ->
              switch
                when leaf then Leaf.of leaf.value + 111
            )
            .should.deep.equal Just Leaf.of 234
