jsc = require 'jsverify'

objectWithProperty = (property) ->
  contextAndValue = jsc.tuple [jsc.map(jsc.json), jsc.string]
  {
    generator: contextAndValue.generator.map ([object, value]) ->
      object[property] = value
      object
    shrink: contextAndValue.shrink
    show: contextAndValue.show
  }

emptyElements = jsc.elements [null, undefined]

module.exports = {
  objectWithProperty
  emptyElements
}