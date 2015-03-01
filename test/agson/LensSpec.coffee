require('chai').should()
jsc = require 'jsverify'
deepEqual = require 'deep-equal'
_ = require 'lodash'

{Just, Nothing} = require 'data.maybe'
lenses = require '../../src/agson/lenses'
traversals = require '../../src/agson/traversals'

laws = require './laws'
LensLaws = require './LensLaws'
generators = require './generators'

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
      LensLaws.identity(identity)(identity)(jsc.json)
      LensLaws.associativity(identity, identity, identity)(jsc.json)


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
        LensLaws.identity(identity)(constant 'foo')(jsc.json)
        LensLaws.associativity(identity, (constant 'foo'), identity)(jsc.json)

  describe 'property', ->
    {property} = lenses
    describe "semantics", ->
      jsc.property 'gets a property on an object', "map(json)", "string", "json", (object, key, value) ->
        object[key] = value
        deepEqual(
          Just value
          property(key).run(object).get()
        )

      jsc.property 'removes property when modified to nothing', "map(json)", "string", "json", (object, key, value) ->
        object[key] = value
        deepEqual(
          Just _.omit object, key
          property(key).run(object).modify(Nothing)
        )

      jsc.property 'changes object property when modified to anything', "map(json)", "string", "json", "json -> json", (object, key, value, f) ->
        object[key] = value
        deepEqual(
          f(object[key])
          property(key).run(object).modify((ma) -> ma.map f).get()[key]
        )

      describe "nesting", ->

        jsc.property 'allows reading from nested objects', 'string', 'string', 'json', (keyOne, keyTwo, v) ->
          tree = {}
          tree[keyOne] = {}
          tree[keyOne][keyTwo] = v

          deepEqual(
            Just v
            property(keyOne).then(property keyTwo).run(tree).get()
          )

        jsc.property 'removes nested property when modified to nothing', 'string', 'string', 'json', (keyOne, keyTwo, v) ->
          tree = {}
          tree[keyOne] = {}
          tree[keyOne][keyTwo] = v

          deepEqual(
            Just do (tree = {}) ->
              tree[keyOne] = {}
              tree
            property(keyOne).then(property keyTwo).run(tree).modify(Nothing)
          )

        jsc.property 'changes nested property when modified to something', 'string', 'string', 'json', 'json -> json', (keyOne, keyTwo, v, f) ->
          tree = {}
          tree[keyOne] = {}
          tree[keyOne][keyTwo] = v
          deepEqual(
            Just do (tree = {}) ->
              tree[keyOne] = {}
              tree[keyOne][keyTwo] = f v
              tree
            property(keyOne).then(property keyTwo).run(tree).modify((ma) -> ma.map f)
          )

    describe 'composition', ->
      LensLaws.identity(identity)(property 'foo')(
        generators.objectWithProperty('foo')
      )
      ###
      TODO: These verify very little because the parametrized case 'foo' is not exercised
      LensLaws.identity(identity)(property 'foo')
      LensLaws.associativity(identity, (property 'foo'), identity)
      ###

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
