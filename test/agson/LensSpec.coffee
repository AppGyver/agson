{Just, Nothing} = require 'data.maybe'
require('chai').should()
lenses = require '../../src/agson/lenses'

describe 'agson.lenses', ->
  describe 'nothing', ->
    it 'gets nothing', ->
      lenses.nothing.run('anything').get().should.deep.equal Nothing()
    it 'sets the same value as passed', ->
      lenses.nothing.run('anything').set('bar').should.deep.equal Just 'bar'

  describe 'identity', ->
    it 'gets the same value as passed', ->
      lenses.identity.run('foo').get().should.deep.equal Just 'foo'
    it 'sets the same value as passed', ->
      lenses.identity.run('foo').set('bar').should.deep.equal Just 'bar'

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
