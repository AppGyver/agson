module.exports =
  # (ab + 0) = (0 + ab)
  identity: (identity) -> (l) -> ({runAll, run, set, modify}) ->
    describe 'identity', ->
      left = identity.then(l)
      right = l.then(identity)

      if set?
        it 'holds for set', ->
          for data in runAll || [run]
            left.run(data).set(set).should.deep.equal right.run(data).set(set)
      
      if modify?
        it 'holds for modify', ->
          for data in runAll || [run]
            left.run(data).modify(modify).should.deep.equal right.run(data).modify(modify)

      it 'holds for get', ->
        for data in runAll || [run]
          left.run(data).get().should.deep.equal right.run(data).get()

  # Most cases, this is what you'll want to prove
  # ab + (bc + cd) = (ab + bc) + cd
  associativity: (ab, bc, cd) -> ({runAll, run, set, modify}) ->
    describe 'associativity', ->
      left = ab.then bc.then cd
      right = (ab.then bc).then cd

      if set?
        it 'holds for set', ->
          for data in runAll || [run]
            left.run(data).set(set).should.deep.equal right.run(data).set(set)

      if modify?
        it 'holds for modify', ->
          for data in runAll || [run]
            left.run(data).modify(modify).should.deep.equal right.run(data).modify(modify)

      it 'holds for get', ->
        for data in runAll || [run]
          left.run(data).get().should.deep.equal right.run(data).get()
