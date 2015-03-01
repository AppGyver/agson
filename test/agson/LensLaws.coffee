jsc = require 'jsverify'
deepEqual = require 'deep-equal'
{Just, Nothing} = require 'data.maybe'

empty = jsc.elements [null, undefined]

module.exports =
  # Verify that the lens 'identity' is the left and right identity for the lens 'l'
  # (ab + 0) = (0 + ab)
  identity: (identity) -> (lens) -> (procase = jsc.json, countercase = empty) ->
    describe "identity", ->
      left = identity.then(lens)
      right = lens.then(identity)

      arbitraryInput = jsc.oneof [procase, countercase]

      describe "get", ->
        jsc.property "#{lens}.get == #{left}.get", arbitraryInput, (a) ->
          deepEqual(
            lens.run(a).get()
            left.run(a).get()
          )

        jsc.property "#{lens}.get == #{right}.get", arbitraryInput, (a) ->
          deepEqual(
            lens.run(a).get()
            right.run(a).get()
          )

      describe "modify to nothing", ->

        jsc.property "#{lens}.modify(Nothing) == #{left}.modify(Nothing)", arbitraryInput, (a) ->
          deepEqual(
            lens.run(a).modify(Nothing)
            left.run(a).modify(Nothing)
          )

        jsc.property "#{lens}.modify(Nothing) == #{right}.modify(Nothing)", arbitraryInput, (a) ->
          deepEqual(
            lens.run(a).modify(Nothing)
            right.run(a).modify(Nothing)
          )

      describe "modify to anything", ->
        jsc.property "#{lens}.modify == #{left}.modify", arbitraryInput, "* -> json", (a, f) ->
          deepEqual(
            lens.run(a).modify((ma) -> ma.map f)
            left.run(a).modify((ma) -> ma.map f)
          )

        jsc.property "#{lens}.modify == #{right}.modify", arbitraryInput, "* -> json", (a, f) ->
          deepEqual(
            lens.run(a).modify((ma) -> ma.map f)
            right.run(a).modify((ma) -> ma.map f)
          )

  # Most cases, this is what you'll want to prove
  # ab + (bc + cd) = (ab + bc) + cd
  associativity: (ab, bc, cd) -> (procase = jsc.json, countercase = empty) ->

    arbitraryInput = jsc.oneof [procase, countercase]

    describe "associativity with lenses #{ab} and #{cd}", ->
      left = ab.then bc.then cd
      right = (ab.then bc).then cd

      jsc.property "#{left}.get == #{right}.get", arbitraryInput, (a) ->
        deepEqual(
          left.run(a).get()
          right.run(a).get()
        )

      jsc.property "#{left}.modify(Nothing) == #{right}.modify(Nothing)", arbitraryInput, (a) ->
        deepEqual(
          left.run(a).modify(Nothing)
          right.run(a).modify(Nothing)
        )

      jsc.property "#{left}.modify == #{right}.modify", arbitraryInput, "* -> json", (a, f) ->
        deepEqual(
          left.run(a).modify((ma) -> ma.map f)
          right.run(a).modify((ma) -> ma.map f)
        )
