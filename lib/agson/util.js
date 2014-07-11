(function() {
  module.exports = {
    notImplemented: function() {
      throw new Error('not implemented');
    },
    maybeMap: function(xs, f) {
      var maybeY, x, ys, _i, _len;
      ys = [];
      for (_i = 0, _len = xs.length; _i < _len; _i++) {
        x = xs[_i];
        maybeY = f(x);
        if (maybeY.isJust) {
          ys.push(maybeY.get());
        }
      }
      return ys;
    }
  };

}).call(this);
