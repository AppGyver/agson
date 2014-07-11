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