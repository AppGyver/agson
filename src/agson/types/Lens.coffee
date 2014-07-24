Maybe = require 'data.maybe'
LensT = require('./LensT')

# Lens a b = LensT Maybe a b
module.exports = LensT(Maybe, Maybe.fromNullable)