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
      it 'flattens sublists', ->
        identity.then(identity)
          .run([['foo'], ['bar']])
          .get()
          .should.deep.equal ['foo', 'bar']

      it 'modifies sublist values', ->
        identity.then(identity)
          .run([['foo'], ['bar']])
          .modify((v) -> v is 'foo')
          .should.deep.equal [[true], [false]]

  describe 'filter', ->
    {filter} = traversals
    it 'accepts a predicate function to determine which items to traverse', ->
      filter((v) -> typeof v is 'string')
        .run(['foo', 123])
        .get()
        .should.deep.equal ['foo']

    it 'obeys identity law', ->
      {identity} = traversals
      left = identity.then filter((v) -> typeof v is 'string')
      right = filter((v) -> typeof v is 'string').then identity

      left.run([['foo'], [123]]).get().should.deep.equal right.run([['foo'], [123]]).get()

