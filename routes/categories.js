'use strict';

var requiredData = require('../modules/requiredData');
var mergeData    = require('../modules/mergeData');
var memcached    = require('../modules/memcached');
var getData      = require('../modules/getData');
var decode       = require('../modules/decode');
var config       = require('../config/default/config');
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

            if (err) console.log('[getCache] Memcached Get Error:', err);

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

        switch (req.baseUrl) {
            case ('/' + config.urls.year):
                getCategories('year', function(render) {
                    callback(render);
                });
                break;
            case ('/' + config.urls.genre):
                getCategories('genre', function(render) {
                    callback(render);
                });
                break;
            case ('/' + config.urls.country):
                getCategories('country', function(render) {
                    callback(render);
                });
                break;
            case ('/' + config.urls.actor):
                getCategories('actor', function(render) {
                    callback(render);
                });
                break;
            case ('/' + config.urls.director):
                getCategories('director', function(render) {
                    callback(render);
                });
                break;
            default:
                res.redirect('/');
        }

    }

    function getCategories(category, callback) {

        async.series({
                "categories": function (callback) {
                    getData.categories(category, function(categories) {
                        callback(null, categories);
                    });
                },
                "top": function (callback) {
                    getData.top(function (movies) {
                        callback(null, movies);
                    });
                }
            },
            function(err, result) {

                if (err) console.log('[getCategories] Sphinx Get Error:', err);

                var required = requiredData.categories(category);
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
                res.render('categories', render, function(err, html) {
                    if (err) return console.log('[renderData] Render Error.', err);
                    res.send(html);
                    if (config.cache.time && html) {
                        memcached.set(
                            urlHash,
                            html,
                            config.cache.time,
                            function (err) {
                                if (err) console.log('[renderData] Memcached Set Error.', err);
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

router.get('/:query/:page?', function(req, res) {

    var query = (req.query.q)
        ? req.query.q.replace(/[^A-zА-яЁё0-9 -]/g, '')
        : req.params.query.replace(/[^A-zА-яЁё0-9 -]/g, '');
    var sort = (req.query.sort)
        ? req.query.sort
        : config.sorting.default;
    var page = (parseInt(req.params.page))
        ? parseInt(req.params.page)
        : 1;

    if (!query) return next({"status": 404, "message": "Not found"});

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

            if (err) console.log('[getCache] Memcached Get Error.', err);

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

        switch (req.baseUrl) {
            case ('/' + config.urls.year):
                getMovies({"year": query}, function(render) {
                    callback(render);
                });
                break;
            case ('/' + config.urls.genre):
                getMovies({"genre": query}, function(render) {
                    callback(render);
                });
                break;
            case ('/' + config.urls.country):
                getMovies({"country": query}, function(render) {
                    callback(render);
                });
                break;
            case ('/' + config.urls.actor):
                getMovies({"actor": query}, function(render) {
                    callback(render);
                });
                break;
            case ('/' + config.urls.director):
                getMovies({"director": query}, function(render) {
                    callback(render);
                });
                break;
            case ('/' + config.urls.type):
                getMovies({"type": query}, function(render) {
                    callback(render);
                });
                break;
            case ('/' + config.urls.search):
                getMovies({"search": query}, function(render) {
                    callback(render);
                });
                break;
            default:
                res.redirect('/');
        }

    }

    function getMovies(query, callback) {

        async.series({
                "movies": function (callback) {
                    getData.movies(query, sort, page, 'category', function (movies) {
                        callback(null, movies);
                    });
                },
                "top": function (callback) {
                    if (config.top_category) {
                        getData.movies(query, config.top_category, 1, 'top_category', function(movies) {
                            if (movies.length) {
                                callback(null, movies);
                            }
                            else {
                                getData.top(function (movies) {
                                    callback(null, movies);
                                });
                            }
                        });
                    }
                    else {
                        getData.top(function (movies) {
                            callback(null, movies);
                        });
                    }
                }
            },
            function(err, result) {

                if (err) console.log('Movies Get Error:', err);

                var required = requiredData.category(query, sort, page, result.movies);
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
                res.render('category', render, function(err, html) {
                    if (err) return console.log('[renderData] Render Error.', err);
                    res.send(html);
                    if (config.cache.time && html) {
                        memcached.set(
                            urlHash,
                            html,
                            config.cache.time,
                            function (err) {
                                if (err) console.log('[renderData] Memcached Set Error.', err);
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
