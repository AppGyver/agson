jsc = require 'jsverify'
deepEqual = require 'deep-equal'
{Just, Nothing} = require 'data.maybe'

module.exports =
  # Verify that the lens 'identity' is the left and right identity for the lens 'l'
  # (ab + 0) = (0 + ab)
  identity: (identity) -> (l) ->
    describe "identity with lens #{identity.toString()}", ->
      left = identity.then(l)
      right = l.then(identity)

      describe "get", ->
        jsc.property "left identity", "json", (a) ->
          deepEqual(
            Just a
            left.run(a).get()
          )

        jsc.property "right identity", "json", (a) ->
          deepEqual(
            Just a
            right.run(a).get()
          )

      describe "modify to nothing", ->

        jsc.property "left identity", "json", (a) ->
          deepEqual(
            Nothing()
            left.run(a).modify(Nothing)
          )

        jsc.property "right identity", "json", (a) ->
          deepEqual(
            Nothing()
            right.run(a).modify(Nothing)
          )

      describe "modify to anything", ->
        jsc.property "left identity", "json", "json -> json", (a, f) ->
          deepEqual(
            Just f a
            left.run(a).modify((ma) -> ma.map f)
          )

        jsc.property "right identity", "json", "json -> json", (a, f) ->
          deepEqual(
            Just f a
            right.run(a).modify((ma) -> ma.map f)
          )

  # Most cases, this is what you'll want to prove
  # ab + (bc + cd) = (ab + bc) + cd
  associativity: (ab, cd) -> (bc) ->
    describe "associativity with lenses #{ab} and #{cd}", ->
      left = ab.then bc.then cd
      right = (ab.then bc).then cd

      jsc.property "get", "json", (a) ->
        deepEqual(
          left.run(a).get()
          right.run(a).get()
        )

      jsc.property "modify to nothing", "json", (a) ->
        deepEqual(
          left.run(a).modify(Nothing)
          right.run(a).modify(Nothing)
        )

      jsc.property "modify to anything", "json", "json -> json", (a, f) ->
        deepEqual(
          left.run(a).modify((ma) -> ma.map f)
          right.run(a).modify((ma) -> ma.map f)
        )
