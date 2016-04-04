'use strict';

var config = require('../config/config');
var mysql  = require('mysql');

var parse = config.sphinx.split(':');

var host = parse[0] || '127.0.0.1';
var port = parse[1] || '9306';

module.exports = mysql.createPool({localAddress: host, port: port});