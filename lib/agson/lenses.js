(function() {
  var Just, Lens, Nothing, constant, definedAt, filter, fromNullable, identity, lens, nothing, property, _ref;

  _ref = require('data.maybe'), Just = _ref.Just, Nothing = _ref.Nothing, fromNullable = _ref.fromNullable;

  Lens = require('./Lens');

  lens = Lens.of;

  nothing = lens(function() {
    return {
      set: function(b) {
        return Just(b);
      },
      get: Nothing
    };
  });

  identity = lens(function(a) {
    return {
      set: function(b) {
        return Just(b);
      },
      get: function() {
        return Just(a);
      }
    };
  });

  constant = function(value) {
    return lens(function() {
      return {
        set: function() {
          return Nothing();
        },
        get: function() {
          return Just(value);
        }
      };
    });
  };

  property = function(key) {
    return lens(function(object) {
      if (object == null) {
        throw new TypeError("Input object must not be null");
      }
      return {
        set: function(value) {
          object[key] = value;
          return Just(object);
        },
        get: function() {
          return fromNullable(object[key]);
        }
      };
    });
  };

  filter = function(predicate) {
    return lens(function(a) {
      return {
        set: function(a) {
          if (predicate(a)) {
            return Just(a);
          } else {
            return Nothing();
          }
        },
        get: function() {
          if (predicate(a)) {
            return Just(a);
          } else {
            return Nothing();
          }
        }
      };
    });
  };

  definedAt = function(abl) {
    return function(a) {
      return abl.run(a).get().isJust;
    };
  };

  module.exports = {
    nothing: nothing,
    identity: identity,
    constant: constant,
    property: property,
    filter: filter,
    definedAt: definedAt
  };

}).call(this);
