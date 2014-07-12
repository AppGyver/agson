require('chai').should()
traversals = require '../../src/agson/traversals'
lenses = require '../../src/agson/lenses'

laws =
  identity: (traversal) -> ({run, modify}) ->
    {identity} = traversals
    describe 'identity law', ->
      left = right = null
      before ->
        left = traversal.then(identity).run(run)
        right = identity.then(traversal).run(run)

      it 'holds for get', ->
        left.get().should.deep.equal right.get()

      it 'holds for set', ->
        left.modify(modify).should.deep.equal right.modify(modify)

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
      it 'modifies sublist values', ->
        each.then(each)
          .run([['foo'], ['bar']])
          .modify((v) -> v is 'foo')
          .should.deep.equal [[true], [false]]

      laws.identity(each) {
        run: ['foo', 'bar']
        modify: (v) -> v + 'qux'
      }

  describe 'where', ->
    {where} = traversals
    strings = where((v) -> typeof v is 'string')
    it 'accepts a predicate function to determine which items to select for update', ->
      strings
        .run(['foo', 123])
        .set('bar')
        .should.deep.equal ['bar', 123]

    it 'filters get output', ->
      strings
        .run(['foo', 123])
        .get()
        .should.deep.equal ['foo']

    describe 'composition', ->
      laws.identity(strings) {
        run: ['foo', 123]
        modify: (v) -> v + 'qux'
      }


  describe 'accept', ->
    {accept} = traversals
    strings = accept (v) -> typeof v is 'string'

    it 'accepts a predicate function to determine which collections to traverse', ->
      strings
        .run('foo')
        .get()
        .should.equal 'foo'

    describe 'composition', ->
      laws.identity(strings) {
        run: 'foo'
        modify: (v) -> v + 'bar'
      }
