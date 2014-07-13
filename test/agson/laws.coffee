module.exports =
  identity: (identity) -> (l) -> ({runAll, run, set, modify}) ->
    describe 'identity law', ->
      
      if set?
        it 'holds for set', ->
          for data in runAll || [run]
            left = identity.then(l).run(data)
            right = l.then(identity).run(data)
            left.set(set).should.deep.equal right.set(set)
      
      if modify?
        it 'holds for modify', ->
          for data in runAll || [run]
            left = identity.then(l).run(data)
            right = l.then(identity).run(data)
            left.modify(modify).should.deep.equal right.modify(modify)

      it 'holds for get', ->
        for data in runAll || [run]
          left = identity.then(l).run(data)
          right = l.then(identity).run(data)
          left.get().should.deep.equal right.get()
