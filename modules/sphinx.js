'use strict';

var memcached = require('../modules/memcached');
var config    = require('../config/config');
var mysql     = require('mysql');
var md5       = require('md5');

function dbConnection(sphinxQuery, callback) {

    if (config.cache.time) {

        var hash = md5(sphinxQuery);

        memcached.get(hash, function (err, results) {

            if (err) console.log('Memcached Get Error:', err);

            if (results) {

                callback(err, results);

            }
            else {

                getSphinx();

            }

        });
        
    }
    else {

        getSphinx();
        
    }
    
    function getSphinx() {

        var parse = config.sphinx.addr.split(':');

        var sphinxConnection = {
            host: parse[0] || '127.0.0.1',
            port: parse[1] || '9306'
        };

        var connection = mysql.createConnection(sphinxConnection);

        connection.connect(function(err) {

            if (err !== null) {

                console.log('[SPHINX] Error connection.');

                callback(err);

            }
            else {

                connection.query(sphinxQuery, function(err, results) {

                    connection.end();

                    callback(err, results);

                });

            }
        });
        
    }

}

module.exports = dbConnection;