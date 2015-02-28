require('chai').should()
jsc = require 'jsverify'
deepEqual = require 'deep-equal'

{Just, Nothing} = require 'data.maybe'
lenses = require '../../src/agson/lenses'
traversals = require '../../src/agson/traversals'

laws = require './laws'

describe 'agson.lenses', ->
  {identity} = lenses

  describe 'nothing', ->
    {nothing} = lenses

    jsc.property "gets nothing from value", "json", (v) ->
      deepEqual(
        Nothing()
        nothing.run(v).get()
      )

    jsc.property "sets nothing as value", "json", "json", (a, b) ->
      deepEqual(
        Nothing()
        nothing.run(a).set(b)
      )

    jsc.property "refuses modification to value", "json", (a) ->
      deepEqual(
        Nothing()
        nothing.run(a).modify(-> throw new Error 'should not get here')
      )

  describe 'identity', ->
    describe "semantics", ->
      it 'gets the same value as passed', ->
        identity
          .run('foo')
          .get()
          .should.deep.equal Just 'foo'
      it 'sets the same value as passed', ->
        identity
          .run('foo')
          .set(Just 'bar')
          .should.deep.equal Just 'bar'
      it 'modifies value with the same value as passed', ->
        identity
          .run('foo')
          .modify((v) -> v + 'bar')
          .get()
          .should.deep.equal Just 'foobar'

    describe 'composition', ->
      laws.identity(identity)(identity) {
        run: 'foo'
        set: 'bar'
      }
      laws.associativity(
        identity
        identity
        identity
      ) {
        run: 'foo'
        set: 'bar'
      }

  describe 'constant', ->
    {constant} = lenses
    it 'ignores value', ->
      constant('foo')
        .run('whatever')
        .get()
        .should.deep.equal Just 'foo'
    it 'ignores set', ->
      constant('foo')
        .run('whaterver')
        .set('bar')
        .should.deep.equal Just 'foo'

    describe 'composition', ->
      laws.identity(identity)(constant('foo')) {
        run: 'bar'
        set: 'bar'
      }
      laws.associativity(
        constant('foo')
        constant('bar')
        constant('qux')
      ) {
        run: 'anything'
        set: 'anything'
      }

  describe 'property', ->
    {property} = lenses
    it 'gets a property on an object', ->
      property('foo')
        .run({ foo: 'bar' })
        .get()
        .should.deep.equal Just 'bar'
      property('bar')
        .run({})
        .get()
        .should.deep.equal Nothing()

    it 'sets a property on an object', ->
      property('foo')
        .run({ foo: 'whatever'})
        .set(Just 'bar')
        .should.deep.equal Just {
          foo: 'bar'
        }

    it 'does set property if it is not there', ->
      property('foo')
        .run({})
        .set(Just 'bar')
        .should.deep.equal Just foo: 'bar'

      property('foo')
        .run({})
        .set(Nothing())
        .should.deep.equal Just {}

    describe 'composition', ->
      it 'allows access to nested objects', ->
        [foo, bar] = [property('foo'), property('bar')]
        foo.then(bar)
          .run({ foo: bar: 'qux' })
          .get()
          .should.deep.equal Just 'qux'
        foo.then(bar)
          .run({ foo: bar: 'qux' })
          .set(Just 'baz')
          .should.deep.equal Just {
            foo: bar: 'baz'
          }

      laws.identity(identity)(property('foo')) {
        runAll: [
          { foo: 'bar' }
          {}
        ]
        set: 'qux'
      }

      laws.associativity(
        property 'foo'
        property 'bar'
        property 'qux'
      ) {
        runAll: [
          { foo: bar: qux: 123 }
          { foo: bar: 123 }
          { foo: 123 }
          {}
        ]
        set: 'qux'
      }
