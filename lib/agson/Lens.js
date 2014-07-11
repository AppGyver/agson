(function() {
  var Lens, MaybeStore, Store, notImplemented,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  notImplemented = require('./util').notImplemented;

  Store = require('./Store');

  MaybeStore = (function(_super) {
    __extends(MaybeStore, _super);

    function MaybeStore() {
      return MaybeStore.__super__.constructor.apply(this, arguments);
    }

    MaybeStore.of = function(s) {
      return new ((function(_super1) {
        __extends(_Class, _super1);

        function _Class() {
          return _Class.__super__.constructor.apply(this, arguments);
        }

        _Class.prototype.set = s.set || notImplemented;

        _Class.prototype.get = s.get || notImplemented;

        return _Class;

      })(MaybeStore));
    };

    MaybeStore.prototype.modify = function(f) {
      return this.get().map(f).chain(this.set);
    };

    return MaybeStore;

  })(Store);

  module.exports = Lens = (function() {
    function Lens() {
      this.then = __bind(this.then, this);
    }

    Lens.of = function(fs) {
      return new ((function(_super) {
        __extends(_Class, _super);

        function _Class() {
          return _Class.__super__.constructor.apply(this, arguments);
        }

        _Class.prototype.run = function(a) {
          return MaybeStore.of(fs(a));
        };

        return _Class;

      })(Lens));
    };

    Lens.prototype.run = notImplemented;

    Lens.prototype.then = function(bc) {
      return Lens.of((function(_this) {
        return function(a) {
          return {
            set: function(c) {
              var abs;
              abs = _this.run(a);
              return abs.get().chain(function(b) {
                var bcs;
                bcs = bc.run(b);
                return bcs.set(c).chain(function(b) {
                  return abs.set(b);
                });
              });
            },
            get: function() {
              return _this.run(a).get().chain(function(b) {
                return bc.run(b).get();
              });
            }
          };
        };
      })(this));
    };

    return Lens;

  })();

}).call(this);
