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
    {identity} = lenses

    it 'accepts a lens for peering into each element', ->
      each(identity).run(['foo', 'bar']).get().should.deep.equal ['foo', 'bar']

    it 'can set values through the lens', ->
      each(identity).run([
        'foo'
        'bar'
      ]).set('qux').should.deep.equal ['qux', 'qux']

    it 'can modify values through the lens', ->
      each(identity).run([
        'foo'
        'bar'
      ]).modify((v) -> v + 'qux').should.deep.equal ['fooqux', 'barqux']

    describe 'composition', ->
      it 'modifies sublist values', ->
        each(identity).then(each(identity))
          .run([['foo'], ['bar']])
          .modify((v) -> v is 'foo')
          .should.deep.equal [[true], [false]]

      laws.identity(each(identity)) {
        run: ['foo', 'bar']
        modify: (v) -> v + 'qux'
      }

      describe 'with property lens', ->
        {property} = lenses
        it 'can pick properties from a list', ->
          each(property 'foo').run([
            { foo: 'bar' }
            { foo: 'qux' }
            { bar: 'whatever' }
          ])
          .get()
          .should.deep.equal ['bar', 'qux']

        it 'can modify properties on objects in a list', ->
          each(property 'foo').run([
            { foo: 'bar' }
            { foo: 'qux' }
            { bar: 'whatever' }
          ])
          .set('baz')
          .should.deep.equal [
            { foo: 'baz' }
            { foo: 'baz' }
            { bar: 'whatever' }
          ]


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
