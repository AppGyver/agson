jsc = require 'jsverify'

mapGenerator = (arb, f) ->
  {
    generator: arb.generator.map f
    shrink: arb.shrink
    show: arb.show
  }

objectWithProperty = (property) ->
  contextAndValue = jsc.tuple [jsc.map(jsc.json), jsc.string]
  mapGenerator contextAndValue, ([object, value]) ->
    object[property] = value
    object

objectWithoutProperty = (property) ->
  jsc.suchthat jsc.map(jsc.json), (object) ->
    !object[property]?

nestedObjectsWithProperties = (properties) ->
  # Slightly increase hit rate by requiring path to be lengthy enough
  path = jsc.suchthat jsc.array(jsc.elements properties), (path) ->
    path.length >= properties.length

  pathAndLeaf = jsc.pair(
    path
    jsc.json
  )

  mapGenerator pathAndLeaf, ([path, leaf]) ->
    # This begs for recursion
    root = {}
    node = root

    while path.length
      p = path.pop()
      if path.length
        node[p] = {}
        node = node[p]
      else
        node[p] = leaf

    root

emptyElements = jsc.elements [null, undefined]

module.exports = {
  objectWithProperty
  objectWithoutProperty
  nestedObjectsWithProperties
  emptyElements
}
