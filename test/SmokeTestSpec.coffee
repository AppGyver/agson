require('chai').should()

describe "agson", ->
  it "should be an object", ->
    require('../src/agson').should.be.an.object
