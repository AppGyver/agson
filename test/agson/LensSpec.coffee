{Just, Nothing} = require 'data.maybe'
require('chai').should()
lenses = require '../../src/agson/lenses'

laws =
  identity: (lens) -> ({run, set}) ->
    {identity} = lenses
    describe 'identity law', ->
      left = right = null
      before ->
        left = identity.then(lens).run(run)
        right = lens.then(identity).run(run)

      it 'holds for set', ->
        left.set(set).should.deep.equal right.set(set)
      it 'holds for get', ->
        left.get().should.deep.equal right.get()

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

    laws.identity(identity) {
      run: 'foo'
      set: 'bar'
    }

  describe 'constant', ->
    {constant} = lenses
    it 'ignores value', ->
      constant('foo').run('whatever').get().should.deep.equal Just 'foo'
    it 'ignores set', ->
      constant('foo').run('whaterver').set('bar').should.deep.equal Nothing()

    laws.identity(constant('foo')) {
      run: 'bar'
      set: 'bar'
    }

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
    {filter, definedAt, property} = lenses
    withFoo = definedAt property 'foo'

    it 'will succeed if getting succeeds', ->
      withFoo({ foo: 'bar' }).should.be.true
      withFoo({ qux: 'bar' }).should.be.false

