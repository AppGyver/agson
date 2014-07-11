{Just, Nothing} = require 'data.maybe'
require('chai').should()
lenses = require '../../src/agson/lenses'

describe 'agson.lenses', ->
  describe 'nothing', ->
    {nothing} = lenses
    it 'gets nothing', ->
      nothing.run('anything').get().should.deep.equal Nothing()
    it 'sets the same value as passed', ->
      nothing.run('anything').set('bar').should.deep.equal Just 'bar'
    it 'refuses modification', ->
      nothing.run('foo')
        .modify(-> throw new Error 'should not get here')
        .should.deep.equal Nothing()

  describe 'identity', ->
    {identity} = lenses
    it 'gets the same value as passed', ->
      identity.run('foo').get().should.deep.equal Just 'foo'
    it 'sets the same value as passed', ->
      identity.run('foo').set('bar').should.deep.equal Just 'bar'
    it 'modifies value with the same value as passed', ->
      identity.run('foo')
        .modify((v) -> v + 'bar')
        .should.deep.equal Just 'foobar'

  describe 'constant', ->
    it 'ignores value', ->
      lenses.constant('foo').run('whatever').get().should.deep.equal Just 'foo'
    it 'ignores set', ->
      lenses.constant('foo').run('whaterver').set('bar').should.deep.equal Nothing()

  describe 'property', ->
    it 'gets a property on an object', ->
      lenses.property('foo').run({ foo: 'bar' }).get().should.deep.equal Just 'bar'
      lenses.property('bar').run({}).get().should.deep.equal Nothing()

    it 'sets a property on an object', ->
      lenses.property('foo').run({ foo: 'whatever'}).set('bar').should.deep.equal Just {
        foo: 'bar'
      }

  describe 'composition', ->
    it 'obeys identity law', ->
      [id, foo] = [lenses.identity, lenses.constant('foo')]
      id.then(id).run('foo').get().should.deep.equal Just 'foo'
      id.then(id).run('whatever').set('foo').should.deep.equal Just 'foo'

      foo.then(id).run('whatever').get().should.deep.equal Just 'foo'
      foo.then(id).run('whatever').set('anything').should.deep.equal Nothing()

      id.then(foo).run('whatever').get().should.deep.equal Just 'foo'
      id.then(foo).run('whatever').set('anything').should.deep.equal Nothing()

    it 'allows access to nested objects', ->
      [foo, bar] = [lenses.property('foo'), lenses.property('bar')]
      foo.then(bar).run({ foo: bar: 'qux' }).get().should.deep.equal Just 'qux'
      foo.then(bar).run({ foo: bar: 'qux' }).set('baz').should.deep.equal Just {
        foo: bar: 'baz'
      }

  describe 'traversal', ->
    it 'accepts a lens to traverse an array with', ->
      {traversal, identity, constant} = lenses
      traversal(identity).run(['foo', 'bar']).get().should.deep.equal Just ['foo', 'bar']
      traversal(constant('qux')).run(['foo', 'bar']).get().should.deep.equal Just ['qux', 'qux']

    it 'removes elements that get fails on', ->
      {traversal, nothing} = lenses
      traversal(nothing).run(['foo', 'bar']).get().should.deep.equal Just []

    it 'sets each value in the array', ->
      {traversal, identity} = lenses
      traversal(identity).run([
        'foo'
        'bar'
      ]).set('qux').should.deep.equal Just ['qux', 'qux']

    it 'modifies each value in the array by giving out the value', ->
      {traversal, identity} = lenses
      traversal(identity).run([
        'foo'
        'bar'
      ]).modify((v) -> v + 'qux').should.deep.equal Just ['fooqux', 'barqux']

    it 'allows picking values from objects when combined with property', ->
      {traversal, property} = lenses
      traversal(property('foo')).run([
        { foo: 'bar' }
        { foo: 'qux' }
      ]).get().should.deep.equal Just ['bar', 'qux']
