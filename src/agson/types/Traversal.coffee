LensT = require './LensT'
List = require './List'

# Traversal a b = LensT List a b
module.exports = LensT List, List.fromArray
