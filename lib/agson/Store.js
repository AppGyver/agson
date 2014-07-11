(function() {
  var Store, notImplemented;

  notImplemented = require('./util').notImplemented;

  module.exports = Store = (function() {
    function Store() {}

    Store.prototype.set = notImplemented;

    Store.prototype.get = notImplemented;

    Store.prototype.modify = notImplemented;

    return Store;

  })();

}).call(this);
