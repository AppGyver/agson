{Just, Nothing} = require 'data.maybe'
require('chai').should()
lenses = require '../../src/agson/lenses'

describe 'agson.lenses', ->
  describe 'identity', ->
    it 'gets the same value as passed', ->
      lenses.identity.run('foo').get().should.deep.equal Just 'foo'
    it 'sets the same value as passed', ->
      lenses.identity.run('foo').set('bar').should.deep.equal Just 'bar'
