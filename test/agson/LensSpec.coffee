require('chai').should()
jsc = require 'jsverify'
deepEqual = require 'deep-equal'

{Just, Nothing} = require 'data.maybe'
lenses = require '../../src/agson/lenses'
traversals = require '../../src/agson/traversals'

laws = require './laws'
LensLaws = require './LensLaws'

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
      jsc.property "gets the value itself", "json", (v) ->
        deepEqual(
          Just v
          identity.run(v).get()
        )

      jsc.property "sets the value to the one passed", "json", "json", (a, b) ->
        deepEqual(
          Just b
          identity.run(a).set(b)
        )

      jsc.property "can be modified to nothing", "json", (a) ->
        deepEqual(
          Nothing()
          identity.run(a).modify(Nothing)
        )

      jsc.property "can be modified to anything", "json", "json", (a, b) ->
        deepEqual(
          Just b
          identity.run(a).modify((ma) -> Just b)
        )

    describe 'composition', ->
      LensLaws.identity(identity)(identity)
      LensLaws.associativity(identity, identity)(identity)


  describe 'constant', ->
    {constant} = lenses
    describe 'semantics', ->

      describe "when input is non-null", ->

        jsc.property 'ignores the value', 'json', 'json', (a, b) ->
          deepEqual(
            Just a
            constant(a).run(b).get()
          )

        jsc.property 'ignores modify to nothing', 'json', 'json', (a, b) ->
          deepEqual(
            Just a
            constant(a).run(b).modify(Nothing)
          )

        jsc.property 'ignores modify to anything', 'json', 'json', 'json -> json', (a, b, f) ->
          deepEqual(
            Just a
            constant(a).run(b).modify((mb) -> mb.map f)
          )

      describe 'composition', ->
        LensLaws.identity(identity)(constant 'foo')
        LensLaws.associativity(identity, identity)(constant 'foo')

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
