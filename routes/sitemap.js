'use strict';

var memcached = require('../modules/memcached');
var getData   = require('../modules/getData');
var decode    = require('../modules/decode');
var config    = require('../config/config');
var express   = require('express');
var md5       = require('md5');

var router    = express.Router();

router.get('/?', function(req, res) {

    var url = decode(config.domain + req.originalUrl);
    var urlHash = md5(url.toLowerCase());
    console.time(url);

    getCategories('year', function(categories) {
        renderData(categories, 'index');
    });

    function getCategories(category, callback) {

        if (config.cache.time) {

            memcached.get(urlHash, function (err, categories) {

                if (err) throw err;

                if (categories) {

                    callback(categories);

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

            getData.categories(category, function(categories) {

                callback(categories);

                if (categories && config.cache.time) {
                    memcached.set(
                        urlHash,
                        categories,
                        config.cache.time,
                        function (err) {
                            if (err) {
                                console.log(err);
                            }
                        }
                    );
                }

            });

        }

    }

    function renderData(data, category) {

        res.header('Content-Type', 'application/xml');
        res.render('sitemap', {
            "protocol": config.protocol,
            "domain": config.domain,
            "urls": config.urls,
            "category": category,
            "data": data
        });

        console.timeEnd(url);

    }

});

router.get('/:type/:year?', function(req, res) {

    var url = decode(config.domain + req.originalUrl);
    var urlHash = md5(url.toLowerCase());
    console.time(url);

    switch (req.params.type) {
        case (config.urls.year):
            if (parseInt(req.params.year)) {
                getMovies(parseInt(req.params.year));
            }
            else {
                getCategories('year', function(categories) {
                    renderData(categories, 'year');
                });
            }
            break;
        case (config.urls.genre):
            getCategories('genre', function(categories) {
                renderData(categories, 'genre');
            });
            break;
        case (config.urls.country):
            getCategories('country', function(categories) {
                renderData(categories, 'country');
            });
            break;
        case (config.urls.actor):
            getCategories('actor', function(categories) {
                renderData(categories, 'actor');
            });
            break;
        case (config.urls.director):
            getCategories('director', function(categories) {
                renderData(categories, 'director');
            });
            break;
        default:
            getCategories('year', function(categories) {
                renderData(categories, 'index');
            });
    }

    function getCategories(category, callback) {

        if (config.cache.time) {

            memcached.get(urlHash, function (err, categories) {

                if (err) throw err;

                if (categories) {

                    callback(categories);

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

            getData.categories(category, function(categories) {

                callback(categories);

                if (categories && config.cache.time) {
                    memcached.set(
                        urlHash,
                        categories,
                        config.cache.time,
                        function (err) {
                            if (err) {
                                console.log(err);
                            }
                        }
                    );
                }

            });

        }

    }

    function getMovies(year) {

        if (config.cache.time) {

            memcached.get(urlHash, function (err, movies) {

                if (err) throw err;

                if (movies) {

                    if (movies.length) {

                        renderData(movies, 'movies');

                    }
                    else {

                        res.send('');

                    }

                    console.timeEnd(url);

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

            getData.movies({"year": year}, 'premiere-up', 1, 'sitemap', function (movies) {

                if (movies && movies.length) {

                    renderData(movies, 'movies');

                }
                else {

                    res.send('');

                }

                if (movies && config.cache.time) {
                    memcached.set(
                        urlHash,
                        movies,
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

    }

    function renderData(data, category) {

        res.header('Content-Type', 'application/xml');
        res.render('sitemap', {
            "protocol": config.protocol,
            "domain": config.domain,
            "urls": config.urls,
            "category": category,
            "data": data
        });

        console.timeEnd(url);

    }

});

module.exports = router;