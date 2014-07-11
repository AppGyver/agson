{Just, Nothing} = require 'data.maybe'
require('chai').should()
lenses = require '../../src/agson/lenses'

describe 'agson.lenses', ->
  describe 'nothing', ->
    {nothing} = lenses
    it 'gets nothing', ->
      nothing.run('anything').get().should.deep.equal Nothing()
    it 'sets the same value as passed', ->
      nothing.run('anything').set('bar').should.deep.equal Just 'bar'
    it 'refuses modification', ->
      nothing.run('foo')
        .modify(-> throw new Error 'should not get here')
        .should.deep.equal Nothing()

  describe 'identity', ->
    {identity} = lenses
    it 'gets the same value as passed', ->
      identity.run('foo').get().should.deep.equal Just 'foo'
    it 'sets the same value as passed', ->
      identity.run('foo').set('bar').should.deep.equal Just 'bar'
    it 'modifies value with the same value as passed', ->
      identity.run('foo')
        .modify((v) -> v + 'bar')
        .should.deep.equal Just 'foobar'
    it 'obeys identity law', ->
      identity.then(identity).run('foo').get().should.deep.equal Just 'foo'
      identity.then(identity).run('whatever').set('foo').should.deep.equal Just 'foo'

  describe 'constant', ->
    it 'ignores value', ->
      lenses.constant('foo').run('whatever').get().should.deep.equal Just 'foo'
    it 'ignores set', ->
      lenses.constant('foo').run('whaterver').set('bar').should.deep.equal Nothing()
    it 'obeys identity law', ->
      [id, foo] = [lenses.identity, lenses.constant('foo')]

      foo.then(id).run('whatever').get().should.deep.equal Just 'foo'
      foo.then(id).run('whatever').set('anything').should.deep.equal Nothing()

      id.then(foo).run('whatever').get().should.deep.equal Just 'foo'
      id.then(foo).run('whatever').set('anything').should.deep.equal Nothing()

  describe 'property', ->
    it 'gets a property on an object', ->
      lenses.property('foo').run({ foo: 'bar' }).get().should.deep.equal Just 'bar'
      lenses.property('bar').run({}).get().should.deep.equal Nothing()

    it 'sets a property on an object', ->
      lenses.property('foo').run({ foo: 'whatever'}).set('bar').should.deep.equal Just {
        foo: 'bar'
      }

    describe 'composition', ->
      it 'allows access to nested objects', ->
        [foo, bar] = [lenses.property('foo'), lenses.property('bar')]
        foo.then(bar).run({ foo: bar: 'qux' }).get().should.deep.equal Just 'qux'
        foo.then(bar).run({ foo: bar: 'qux' }).set('baz').should.deep.equal Just {
          foo: bar: 'baz'
        }

  describe 'traversal', ->
    it 'does nothing on its own', ->
      {traversal} = lenses
      traversal.run(['foo', 'bar']).get().should.deep.equal Just ['foo', 'bar']

    it 'sets each value in the array', ->
      {traversal} = lenses
      traversal.run([
        'foo'
        'bar'
      ]).set('qux').should.deep.equal Just ['qux', 'qux']

    it 'modifies each value in the array by giving out the value', ->
      {traversal} = lenses
      traversal.run([
        'foo'
        'bar'
      ]).modify((v) -> v + 'qux').should.deep.equal Just ['fooqux', 'barqux']

    describe 'composition', ->

      it 'removes elements that get fails on', ->
        {traversal, nothing} = lenses
        traversal.then(nothing).run(['foo', 'bar']).get().should.deep.equal Just []

      it 'allows picking values from objects when combined with property', ->
        {traversal, property} = lenses
        traversal.then(property('foo')).run([
          { foo: 'bar' }
          { foo: 'qux' }
        ]).get().should.deep.equal Just ['bar', 'qux']

      it 'obeys identity', ->
        {traversal, identity} = lenses
        right = identity.then(traversal)
        left = traversal.then(identity)
        right.run(['bar', 'qux']).get().should.deep.equal left.run(['bar', 'qux']).get()

  describe 'filter', ->
    {filter, identity} = lenses
    strings = filter (a) -> typeof a is 'string'

    it 'can decide whether getting a provided lens will succeed', ->
      strings.run('foo').get().should.deep.equal Just 'foo'
      strings.run(123).get().should.deep.equal Nothing()

    it 'can decide whether setting a provided lens will succeed', ->
      strings.run(123).set('foo').should.deep.equal Just 'foo'
      strings.run('foo').set(123).should.deep.equal Nothing()


  describe 'definedAt', ->
    {filter, definedAt, property, traversal} = lenses
    withFoo = definedAt property 'foo'

    it 'will succeed if getting succeeds', ->
      withFoo({ foo: 'bar' }).should.be.true
      withFoo({ qux: 'bar' }).should.be.false

    it 'can combine with filter and traversal', ->
      traversal.then(filter withFoo).run([
        { foo: 'bar' }
        { qux: 'bar' }
      ]).get().should.deep.equal Just [
        { foo: 'bar' }
      ]

