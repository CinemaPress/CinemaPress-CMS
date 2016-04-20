'use strict';

var memcached = require('../modules/memcached');
var getData   = require('../modules/getData');
var decode    = require('../modules/decode');
var config    = require('../config/default/config');
var express   = require('express');
var md5       = require('md5');

var router    = express.Router();

router.get('/?', function(req, res) {

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

        getData.categories('year', function(categories) {

            var render = {
                "protocol" : config.protocol,
                "domain"   : config.domain,
                "urls"     : config.urls,
                "category" : "index",
                "data"     : categories
            };

            callback(render);

        });

    }

    function renderData(render) {

        res.header('Content-Type', 'application/xml');
        if (typeof render === 'object') {
            res.render('sitemap', render, function(err, html) {
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

        console.timeEnd(url);

    }

});

router.get('/:type/:year?', function(req, res) {

    var year = (req.params.year) ? parseInt(req.params.year) : 0;

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

        switch (req.params.type) {
            case (config.urls.year):
                if (year) {
                    getMovies(year, function(render) {
                        callback(render);
                    });
                }
                else {
                    getCategories('year', function(render) {
                        callback(render);
                    });
                }
                break;
            case (config.urls.genre):
                getCategories('genre', function(render) {
                    callback(render);
                });
                break;
            case (config.urls.country):
                getCategories('country', function(render) {
                    callback(render);
                });
                break;
            case (config.urls.actor):
                getCategories('actor', function(render) {
                    callback(render);
                });
                break;
            case (config.urls.director):
                getCategories('director', function(render) {
                    callback(render);
                });
                break;
            default:
                getCategories('year', function(render) {
                    callback(render);
                });
        }

    }

    function getCategories(category, callback) {

        getData.categories(category, function(categories) {

            var render = {
                "protocol" : config.protocol,
                "domain"   : config.domain,
                "urls"     : config.urls,
                "category" : category,
                "data"     : categories
            };

            callback(render);

        });

    }

    function getMovies(year, callback) {

        getData.movies({"year": year}, 'premiere-up', 1, 'sitemap', function (movies) {

            if (movies && movies.length) {

                var render = {
                    "protocol" : config.protocol,
                    "domain"   : config.domain,
                    "urls"     : config.urls,
                    "category" : "movies",
                    "data"     : movies
                };

                callback(render);

            }
            else {

                callback('');

            }

        });

    }

    function renderData(render) {

        res.header('Content-Type', 'application/xml');
        if (typeof render === 'object') {
            res.render('sitemap', render, function(err, html) {
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

        console.timeEnd(url);

    }

});

module.exports = router;