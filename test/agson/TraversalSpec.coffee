require('chai').should()
traversals = require '../../src/agson/traversals'

describe 'agson.traversals', ->
  describe 'identity', ->
    {identity} = traversals
    it 'gets each value in the array', ->
      identity.run(['foo', 'bar']).get().should.deep.equal ['foo', 'bar']

    it 'sets each value in the array', ->
      identity.run([
        'foo'
        'bar'
      ]).set('qux').should.deep.equal ['qux', 'qux']

    it 'modifies each value in the array by giving out the value', ->
      identity.run([
        'foo'
        'bar'
      ]).modify((v) -> v + 'qux').should.deep.equal ['fooqux', 'barqux']

    describe 'composition', ->
      it 'recurses into sublists', ->
        identity.then(identity)
          .run([['foo'], ['bar']])
          .get()
          .should.deep.equal ['foo', 'bar']
