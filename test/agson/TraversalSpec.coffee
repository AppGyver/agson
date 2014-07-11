require('chai').should()
traversals = require '../../src/agson/traversals'
lenses = require '../../src/agson/lenses'

describe 'agson.traversals', ->

  describe 'identity', ->
    {identity} = traversals
    it 'accepts a value and gets it', ->
      identity.run(['foo', 'bar'])
        .get()
        .should.deep.equal ['foo', 'bar']
    
    it 'returns value that is set', ->
      identity.run([])
        .set(['foo'])
        .should.deep.equal ['foo']

    it 'modifies using provided value', ->
      identity.run(['foo'])
        .modify((list) -> list.concat ['bar'])
        .should.deep.equal ['foo', 'bar']

  describe 'each', ->
    {each} = traversals
    it 'gets each value in the array', ->
      each.run(['foo', 'bar']).get().should.deep.equal ['foo', 'bar']

    it 'sets each value in the array', ->
      each.run([
        'foo'
        'bar'
      ]).set('qux').should.deep.equal ['qux', 'qux']

    it 'modifies each value in the array by giving out the value', ->
      each.run([
        'foo'
        'bar'
      ]).modify((v) -> v + 'qux').should.deep.equal ['fooqux', 'barqux']

    describe 'composition', ->
      it 'flattens sublists', ->
        each.then(each)
          .run([['foo'], ['bar']])
          .get()
          .should.deep.equal ['foo', 'bar']

      it 'modifies sublist values', ->
        each.then(each)
          .run([['foo'], ['bar']])
          .modify((v) -> v is 'foo')
          .should.deep.equal [[true], [false]]

      it 'obeys identity law', ->
        {identity} = traversals
        left = each.then(identity).run(['foo', 'bar'])
        right = identity.then(each).run(['foo', 'bar'])
        left.get().should.deep.equal right.get()

  describe 'filter', ->
    {filter} = traversals
    it 'accepts a predicate function to determine which items to traverse', ->
      filter((v) -> typeof v is 'string')
        .run(['foo', 123])
        .get()
        .should.deep.equal ['foo']
