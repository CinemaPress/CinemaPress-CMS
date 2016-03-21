'use strict';

var getData      = require('../modules/getData');
var requiredData = require('../modules/requiredData');
var mergeData    = require('../modules/mergeData');
var config       = require('../config/config');
var memcached    = require('../modules/memcached');
var express      = require('express');
var async        = require('async');
var md5          = require('md5');
var router       = express.Router();

router.get('/', function(req, res) {

    var url = decodeURIComponent(config.domain + req.originalUrl);
    var urlHash = md5(url.toLowerCase());
    console.time(url);

    if (config.cache.time) {

        memcached.get(urlHash, function (err, render) {

            if (err) throw err;

            if (render) {

                if (config.theme == 'skeleton') {
                    res.json(render);
                }
                else {
                    res.render('index', render);
                }

            }
            else {

                run();

            }

        });

    }
    else {

        run();

    }

    function run() {

        async.series({
                "top": function (callback) {
                    getData.top(function (movies) {
                        callback(null, movies);
                    });
                },
                "movies": function(callback) {
                    async.series({
                            "type": function(callback) {
                                if (config.index.type.keys != '') {
                                    getData.additional('type', config.index.type.keys, config.index.type.sort, 'index', function (movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "country": function(callback) {
                                if (config.index.country.keys != '') {
                                    getData.additional('country', config.index.country.keys, config.index.country.sort, 'index', function (movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "genre": function(callback) {
                                if (config.index.genre.keys != '') {
                                    getData.additional('genre', config.index.genre.keys, config.index.genre.sort, 'index', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "director": function(callback) {
                                if (config.index.director.keys != '') {
                                    getData.additional('director', config.index.director.keys, config.index.director.sort, 'index', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "actor": function(callback) {
                                if (config.index.actor.keys != '') {
                                    getData.additional('actor', config.index.actor.keys, config.index.actor.sort, 'index', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "year": function(callback) {
                                if (config.index.year.keys != '') {
                                    getData.additional('year', config.index.year.keys, config.index.year.sort, 'index', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            }
                        },
                        function(err, result) {

                            if (err) console.error(err.message);

                            callback(null, result);

                        });
                }
            },
            function(err, result) {

                if (err) console.error(err.message);

                var required = requiredData.index();
                var render = mergeData(result, required);

                if (config.theme == 'skeleton') {
                    res.json(render);
                }
                else {
                    res.render('index', render);
                }

                if (render && config.cache.time) {
                    memcached.set(
                        urlHash,
                        render,
                        config.cache.time,
                        function (err) {
                            if (err) {
                                console.log(err);
                            }
                        }
                    );
                }

                console.timeEnd(url);

            });

    }

});

module.exports = router;