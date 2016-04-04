'use strict';

var config    = require('../config/config');
var Memcached = require('memcached');

config.cache.addr = config.cache.addr || '127.0.0.1:11211';

module.exports = new Memcached(config.cache.addr);