(function() {
  var ListStore, Store, Traversal, notImplemented,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  notImplemented = require('./util').notImplemented;

  Store = require('./Store');

  ListStore = (function(_super) {
    __extends(ListStore, _super);

    function ListStore() {
      return ListStore.__super__.constructor.apply(this, arguments);
    }

    ListStore.of = function(s) {
      return new ((function(_super1) {
        __extends(_Class, _super1);

        function _Class() {
          return _Class.__super__.constructor.apply(this, arguments);
        }

        _Class.prototype.modify = s.modify || notImplemented;

        _Class.prototype.get = s.get || notImplemented;

        return _Class;

      })(ListStore));
    };

    ListStore.prototype.set = function(b) {
      return this.modify(function() {
        return b;
      });
    };

    return ListStore;

  })(Store);

  module.exports = Traversal = (function() {
    function Traversal() {}

    Traversal.prototype.run = notImplemented;

    Traversal.prototype.then = notImplemented;

    Traversal.of = function(fs) {
      return new ((function(_super) {
        __extends(_Class, _super);

        function _Class() {
          return _Class.__super__.constructor.apply(this, arguments);
        }

        _Class.prototype.run = function(traversable) {
          return ListStore.of(fs(traversable));
        };

        return _Class;

      })(Traversal));
    };

    return Traversal;

  })();

}).call(this);
