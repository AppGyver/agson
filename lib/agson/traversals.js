(function() {
  var Traversal, identity, traversal;

  Traversal = require('./Traversal');

  traversal = Traversal.of;

  identity = traversal(function(traversable) {
    return {
      modify: function(f) {
        var a, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = traversable.length; _i < _len; _i++) {
          a = traversable[_i];
          _results.push(f(a));
        }
        return _results;
      },
      get: function() {
        return traversable;
      }
    };
  });

  module.exports = {
    identity: identity
  };

}).call(this);
