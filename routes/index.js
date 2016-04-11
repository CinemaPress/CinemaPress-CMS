'use strict';

var requiredData = require('../modules/requiredData');
var mergeData    = require('../modules/mergeData');
var memcached    = require('../modules/memcached');
var getData      = require('../modules/getData');
var decode       = require('../modules/decode');
var config       = require('../config/config');
var express      = require('express');
var async        = require('async');
var md5          = require('md5');

var router       = express.Router();

router.get('/', function(req, res) {

    var url = decode(config.domain + req.originalUrl);
    var urlHash = md5(url.toLowerCase());

    console.time(url);

    getRender(function (render) {

        renderData(render);

    });

    function getRender(callback) {

        if (config.cache.time) {

            getCache(function (render) {
                callback(render);
            });

        }
        else {

            getSphinx(function (render) {
                callback(render);
            });

        }

    }

    function getCache(callback) {

        memcached.get(urlHash, function (err, render) {

            if (err) console.log('Memcached Get Error:', err);

            if (render) {

                callback(render);

            }
            else {

                getSphinx(function (render) {
                    callback(render);
                });

            }

        });

    }

    function getSphinx(callback) {

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

                            if (err) console.log('Movies Get Error:', err);

                            callback(null, result);

                        });
                }
            },
            function(err, result) {

                if (err) console.log('Index Movies Get Error:', err);

                var required = requiredData.index();
                var render = mergeData(result, required);

                callback(render);

            });

    }

    function renderData(render) {

        if (config.theme == 'skeleton') {
            res.json(render);
        }
        else {
            if (typeof render === 'object') {
                res.render('index', render, function(err, html) {
                    if (err) return console.log('Render Error:', err);
                    res.send(html);
                    if (config.cache.time && html) {
                        memcached.set(
                            urlHash,
                            html,
                            config.cache.time,
                            function (err) {
                                if (err) console.log('Memcached Set Error:', err);
                            }
                        );
                    }
                });
            }
            else {
                res.send(render);
            }
        }

        console.timeEnd(url);

    }

});

module.exports = router;