{Just, Nothing} = require 'data.maybe'
require('chai').should()
lenses = require '../../src/agson/lenses'

describe 'agson.lenses', ->
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
      lenses.identity.then(lenses.identity).run('foo').get().should.deep.equal Just 'foo'

      lenses.constant('foo').then(lenses.identity).run('whatever').get().should.deep.equal Just 'foo'

      lenses.identity.then(lenses.constant('foo')).run('whatever').get().should.deep.equal Just 'foo'
