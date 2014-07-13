require('chai').should()
traversals = require '../../src/agson/traversals'
lenses = require '../../src/agson/lenses'

laws = require './laws'

traversalIdentityLaw = laws.identity traversals.identity

describe 'agson.traversals', ->

  describe 'identity', ->
    {identity} = traversals
    it 'accepts a value and gets it', ->
      identity.run(['foo', 'bar'])
        .get()
        .should.deep.equal ['foo', 'bar']
    
    it 'returns value that is set', ->
      identity.run([123])
        .set('foo')
        .should.deep.equal ['foo']

    it 'modifies using provided value', ->
      identity.run(['foo'])
        .modify((item) -> item + 'bar')
        .should.deep.equal ['foobar']

    describe 'composition', ->
      it 'flattens list', ->
        identity.then(identity)
          .run([['foo'], ['bar']])
          .get()
          .should.deep.equal ['foo', 'bar']

      laws.associativity(
        identity
        identity
        identity
      ) {
        run: [[['foo'], ['bar']], [['qux']]]
        set: 123
      }


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

      traversalIdentityLaw(each(identity)) {
        run: [['foo', 'bar']]
        modify: (v) -> v + 'qux'
      }

      {property} = lenses

      laws.associativity(
        each property 'foo'
        each property 'bar'
        each property 'qux'
      ) {
        run: [
          {
            foo: [
              {
                bar: [
                  {
                    qux: 123
                  }
                ]
              }
            ]
          }
          {
            foo: [
              {
                bar: [
                  {
                    qux: 456
                  }
                ]
              }
            ]
          }
        ],
        set: 'foobar'
      }

    describe 'usage', ->
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
        .set(123)
        .should.deep.equal [123, 123]

    it 'filters get output', ->
      strings
        .run(['foo', 123])
        .get()
        .should.deep.equal ['foo']

    describe 'composition', ->
      laws.associativity(
        where (v) -> v instanceof Array
        where (v) -> v instanceof Array
        where (v) -> typeof v is 'string'
      ) {
        run: [ [ [ 'foo', 123 ], 'bar' ], 'qux' ]
        set: 'baz'
        modify: (v) -> v + 'baz'
      }
