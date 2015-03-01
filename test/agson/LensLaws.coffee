jsc = require 'jsverify'
deepEqual = require 'deep-equal'
{Just, Nothing} = require 'data.maybe'

module.exports =
  # Verify that the lens 'identity' is the left and right identity for the lens 'l'
  # (ab + 0) = (0 + ab)
  identity: (identity) -> (lens) ->
    describe "identity", ->
      left = identity.then(lens)
      right = lens.then(identity)

      describe "get", ->
        jsc.property "#{lens}.get == #{left}.get", "json", (a) ->
          deepEqual(
            lens.run(a).get()
            left.run(a).get()
          )

        jsc.property "#{lens}.get == #{right}.get", "json", (a) ->
          deepEqual(
            lens.run(a).get()
            right.run(a).get()
          )

      describe "modify to nothing", ->

        jsc.property "#{lens}.modify(Nothing) == #{left}.modify(Nothing)", "json", (a) ->
          deepEqual(
            lens.run(a).modify(Nothing)
            left.run(a).modify(Nothing)
          )

        jsc.property "#{lens}.modify(Nothing) == #{right}.modify(Nothing)", "json", (a) ->
          deepEqual(
            lens.run(a).modify(Nothing)
            right.run(a).modify(Nothing)
          )

      describe "modify to anything", ->
        jsc.property "#{lens}.modify == #{left}.modify", "json", "json -> json", (a, f) ->
          deepEqual(
            lens.run(a).modify((ma) -> ma.map f)
            left.run(a).modify((ma) -> ma.map f)
          )

        jsc.property "#{lens}.modify == #{right}.modify", "json", "json -> json", (a, f) ->
          deepEqual(
            lens.run(a).modify((ma) -> ma.map f)
            right.run(a).modify((ma) -> ma.map f)
          )

  # Most cases, this is what you'll want to prove
  # ab + (bc + cd) = (ab + bc) + cd
  associativity: (ab, bc, cd) ->
    describe "associativity with lenses #{ab} and #{cd}", ->
      left = ab.then bc.then cd
      right = (ab.then bc).then cd

      jsc.property "#{left}.get == #{right}.get", "json", (a) ->
        deepEqual(
          left.run(a).get()
          right.run(a).get()
        )

      jsc.property "#{left}.modify(Nothing) == #{right}.modify(Nothing)", "json", (a) ->
        deepEqual(
          left.run(a).modify(Nothing)
          right.run(a).modify(Nothing)
        )

      jsc.property "#{left}.modify == #{right}.modify", "json", "json -> json", (a, f) ->
        deepEqual(
          left.run(a).modify((ma) -> ma.map f)
          right.run(a).modify((ma) -> ma.map f)
        )
