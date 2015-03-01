{Just, Nothing} = require 'data.maybe'

require('chai').should()
traversals = require '../../src/agson/traversals'
lenses = require '../../src/agson/lenses'
combinators = require '../../src/agson/combinators'
laws = require './laws'

List = require('../../src/agson/types/List').fromArray

describe 'agson.traversals', ->

  {identity, property} = lenses

  describe 'list', ->
    {list} = traversals

    describe 'semantics', ->
      it 'is the identity for lists', ->
        list
          .run(['foo', 'bar'])
          .get()
          .should.deep.equal List ['foo', 'bar']

      it 'sets each value in a list', ->
        list
          .run(['foo', 'bar'])
          .set('baz')
          .should.deep.equal List ['baz', 'baz']

      it 'maps over the list', ->
        list
          .run(['foo', 'bar'])
          .map((v) -> v + 'qux')
          .should.deep.equal List ['fooqux', 'barqux']

    describe 'composition', ->

      laws.associativity(
        list
        list
        list
      ) {
        run: [
          [ [1], [2, 3] ]
          [ [4, 5, 6] ]
        ]
        map: (v) -> v + 1
        set: 'qux'
      }

      describe 'get', ->

        it 'flattens List List into List', ->
          list
            .then(list)
            .run([['foo', 'bar'], ['qux']])
            .get()
            .should.deep.equal List [ 'foo', 'bar', 'qux' ]

        it 'works with nested lists and objects', ->
          list
            .then(property 'foo')
            .run([{ foo: 'bar'}, { foo: 'qux' }])
            .get()
            .should.deep.equal List ['bar', 'qux']

          property('foo')
            .then(list)
            .run({foo: [ 1, 2, 3 ]})
            .get()
            .should.deep.equal List [ 1, 2, 3 ]

  describe 'object.values', ->
    {object: {values}} = traversals

    it 'lists values from object keys', ->
      values
        .run(foo: 'bar')
        .get()
        .should.deep.equal List ['bar']

    it 'sets each property on an object', ->
      values
        .run(foo: 'bar', qux: 'baz')
        .set('pow')
        .should.deep.equal Just foo: 'pow', qux: 'pow'

    it 'maps over the object values', ->
      values
        .run(foo: 123, bar: 456)
        .map((v) -> v + 111)
        .should.deep.equal Just foo: 234, bar: 567

    describe 'composition', ->
      laws.associativity(
        values
        property 'foo'
        values
      ) {
        run: {
          a: { foo: { bar: 123, qux: 678 } }
          b: { foo: { bar: 456 } }
        }
        map: (v) -> 111 + v
      }

  describe 'recurse', ->
    {property} = lenses
    {list, recurse} = traversals

    describe 'modify', ->
      it 'allows access to each matching level', ->
        foos = property('foo').then recurse -> foos

        foos
          .run(foo: {})
          .map((v) -> v.bar = true ; v)
          .should.deep.equal Just {
            foo:
              bar:
                true
          }

        foos
          .run(foo: foo: {})
          .map((v) -> v.bar = true ; v)
          .should.deep.equal Just {
            foo:
              foo:
                bar: true
              bar: true
          }

        foos
          .run(foo: foo: foo: {})
          .map((v) -> v.bar = true ; v)
          .should.deep.equal Just {
            foo:
              foo:
                foo:
                  bar: true
                bar: true
              bar: true
          }

    describe 'get', ->
      it 'yields a list of matches to any depth', ->
        foos = property('foo').then recurse -> foos

        foos
          .run(foo: 123)
          .get()
          .should.deep.equal Just [
            123
          ]

        foos
          .run(foo: foo: 123)
          .get()
          .should.deep.equal Just [
            123
            foo: 123
          ]

        foos
          .run(foo: foo: foo: 123)
          .get()
          .should.deep.equal Just [
            123
            { foo: 123 }
            { foo: foo: 123 }
          ]

    describe 'parsing recursive datastructures', ->
      {recurse} = traversals
      describe 'cons list', ->
        {product} = combinators

        L =
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
              L.Nil
            )
            .get()
            .should.deep.equal Nothing()

          list
            .run(
              L.Cons 1, L.Nil
            )
            .get()
            .should.deep.equal Just [
              L.Cons 1, L.Nil
            ]

          list
            .run(
              L.Cons 1, L.Cons 2, L.Nil
            )
            .get()
            .should.deep.equal Just [
              L.Cons 2, L.Nil
              L.Cons 1, L.Cons 2, L.Nil
            ]

        it 'preserves structure on modify', ->
          list.run(
            L.Cons 1, L.Cons 2, L.Cons 3, L.Nil
          )
          .map(({head, tail}) -> L.Cons (head + 1), tail)
          .should.deep.equal Just L.Cons 2, L.Cons 3, L.Cons 4, L.Nil
