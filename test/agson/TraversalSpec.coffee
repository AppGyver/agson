{Just, Nothing} = require 'data.maybe'

require('chai').should()
traversals = require '../../src/agson/traversals'
lenses = require '../../src/agson/lenses'
combinators = require '../../src/agson/combinators'
laws = require './laws'

describe 'agson.traversals', ->

  {identity, property} = lenses

  describe 'list', ->
    {list} = traversals

    it 'is the identity for lists', ->
      list
        .run(['foo', 'bar'])
        .get()
        .should.deep.equal Just ['foo', 'bar']

    it 'sets each value in a list', ->
      list
        .run(['foo', 'bar'])
        .set('baz')
        .should.deep.equal Just ['baz', 'baz']

    it 'maps over the list', ->
      list
        .run(['foo', 'bar'])
        .map((v) -> v + 'qux')
        .should.deep.equal Just ['fooqux', 'barqux']

    describe 'composition', ->

      laws.associativity(
        list
        property 'foo'
        list
      ) {
        run: [
          { foo: [ 1, 2, 3 ] }
          { foo: [ 4, 5, 6 ] }
        ]
        map: (v) -> v + 1
        set: 'qux'
      }

      describe 'map', ->
        it 'flattens Maybe List Maybe List into Maybe List List', ->
          list
            .then(list)
            .run([['foo', 'bar']])
            .map((v) -> v + 'qux')
            .should.deep.equal Just [ ['fooqux', 'barqux'] ]

      describe 'get', ->
        it 'does not flatten List List into List to preserve structure', ->
          list
            .then(list)
            .run([['foo', 'bar'], ['qux']])
            .get()
            .should.deep.equal Just [['foo', 'bar'], ['qux']]

        it 'works with nested lists and objects', ->
          list
            .then(property 'foo')
            .run([{ foo: 'bar'}, { foo: 'qux' }])
            .get()
            .should.deep.equal Just ['bar', 'qux']

          property('foo')
            .then(list)
            .run({foo: [ 1, 2, 3 ]})
            .get()
            .should.deep.equal Just [ 1, 2, 3 ]

  describe 'object', ->
    {object} = traversals

    it 'is the identity for objects', ->
      object
        .run(foo: 'bar')
        .get()
        .should.deep.equal Just foo: 'bar'

    it 'sets each property on an object', ->
      object
        .run(foo: 'bar', qux: 'baz')
        .set('pow')
        .should.deep.equal Just foo: 'pow', qux: 'pow'

    it 'maps over the object values', ->
      object
        .run(foo: 123, bar: 456)
        .map((v) -> v + 111)
        .should.deep.equal Just foo: 234, bar: 567

    describe 'composition', ->
      laws.associativity(
        object
        property 'foo'
        object
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
