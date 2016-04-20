'use strict';

var memcached = require('../modules/memcached');
var config    = require('../config/default/config');
var mysql     = require('mysql');
var md5       = require('md5');

function dbConnection(sphinxQuery, callback) {

    var hash = md5(sphinxQuery);

    if (config.cache.time) {

        memcached.get(hash, function (err, results) {

            if (err) console.log('[dbConnection] Memcached Get Error.', err);

            if (results) {

                callback(err, results);

            }
            else {

                getSphinx(function (err, results) {
                    callback(err, results);
                });

            }

        });
        
    }
    else {

        getSphinx(function (err, results) {
            callback(err, results);
        });
        
    }
    
    function getSphinx(callback) {

        var parse = config.sphinx.addr.split(':');

        var sphinxConnection = {
            host: parse[0] || '127.0.0.1',
            port: parse[1] || '9306'
        };

        var connection = mysql.createConnection(sphinxConnection);

        connection.connect(function(err) {

            if (err !== null) {

                console.log('[getSphinx] Error Connection.', err);

                callback(err);

            }
            else {

                connection.query(sphinxQuery, function(err, results) {

                    connection.end();

                    callback(err, results);

                    if (config.cache.time && results) {
                        memcached.set(
                            hash,
                            results,
                            config.cache.time,
                            function (err) {
                                if (err) console.log('[getSphinx] Memcached Set Error.', err);
                            }
                        );
                    }

                });

            }
        });
        
    }

}

module.exports = dbConnection;