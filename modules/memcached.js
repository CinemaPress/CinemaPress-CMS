'use strict';

var config    = require('../config/config');
var Memcached = require('memcached');

module.exports = new Memcached(config.cache.addr);