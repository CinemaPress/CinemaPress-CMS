'use strict';

var getData      = require('../modules/getData');
var requiredData = require('../modules/requiredData');
var mergeData    = require('../modules/mergeData');
var config       = require('../config/config');
var express      = require('express');
var async        = require('async');
var Memcached    = require('memcached');
var md5          = require('md5');
var router       = express.Router();
var memcached    = new Memcached('localhost:11211');

router.get('/:movie/:type?', function(req, res) {

    var url = decodeURIComponent(config.domain + req.originalUrl);
    var urlHash = md5(url);
    console.time(url);

    req.params.movie = '/' + req.params.movie || '';
    req.params.type  = req.params.type || 'single';

    var prefix_id  = config.urls.prefix_id || '/';
    var regexpId   = new RegExp(decodeURIComponent(prefix_id) + '([0-9]{1,7})', 'ig');
    var id         = regexpId.exec(req.params.movie); id = (id) ? parseInt(id[1]) : '';
    var regexpType = new RegExp('(single|online|trailer|download|picture)', 'ig');
    var type       = regexpType.exec(req.params.type); type = (type) ? type[1] : 'single';

    if (!id) return res.status(404).send('Not found');

    var related = {};

    memcached.get(urlHash, function (err, render) {

        if (err) throw err;

        if (render) {

            renderData(res, type, render, url);

        }
        else {

            async.series({
                    "movie": function (callback) {
                        getData.movie(id, function (movie) {
                            related = movie;
                            callback(null, movie);
                        });
                    },
                    "top": function (callback) {
                        getData.top(function (movies) {
                            callback(null, movies);
                        });
                    },
                    "movies": function(callback) {
                        async.series({
                                "countries": function(callback) {
                                    if (related && related.countries && config.relates.indexOf('countries')+1) {
                                        getData.related('country', related.countries, config.related.country.sort, function (movies) {
                                            callback(null, movies);
                                        });
                                    }
                                    else {
                                        callback(null, []);
                                    }
                                },
                                "genres": function(callback) {
                                    if (related && related.genres && config.relates.indexOf('genres')+1) {
                                        getData.related('genre', related.genres, config.related.genre.sort, function(movies) {
                                            callback(null, movies);
                                        });
                                    }
                                    else {
                                        callback(null, []);
                                    }
                                },
                                "directors": function(callback) {
                                    if (related && related.directors && config.relates.indexOf('directors')+1) {
                                        getData.related('director', related.directors, config.related.director.sort, function(movies) {
                                            callback(null, movies);
                                        });
                                    }
                                    else {
                                        callback(null, []);
                                    }
                                },
                                "actors": function(callback) {
                                    if (related && related.actors && config.relates.indexOf('actors')+1) {
                                        getData.related('actor', related.actors, config.related.actor.sort, function(movies) {
                                            callback(null, movies);
                                        });
                                    }
                                    else {
                                        callback(null, []);
                                    }
                                },
                                "country": function(callback) {
                                    if (related && related.country && config.relates.indexOf('countries') === -1 && config.relates.indexOf('country')+1) {
                                        getData.related('country', related.country, config.related.country.sort, function (movies) {
                                            callback(null, movies);
                                        });
                                    }
                                    else {
                                        callback(null, []);
                                    }
                                },
                                "genre": function(callback) {
                                    if (related && related.genre && config.relates.indexOf('genres') === -1 && config.relates.indexOf('genre')+1) {
                                        getData.related('genre', related.genre, config.related.genre.sort, function(movies) {
                                            callback(null, movies);
                                        });
                                    }
                                    else {
                                        callback(null, []);
                                    }
                                },
                                "director": function(callback) {
                                    if (related && related.director && config.relates.indexOf('directors') === -1 && config.relates.indexOf('director')+1) {
                                        getData.related('director', related.director, config.related.director.sort, function(movies) {
                                            callback(null, movies);
                                        });
                                    }
                                    else {
                                        callback(null, []);
                                    }
                                },
                                "actor": function(callback) {
                                    if (related && related.actor && config.relates.indexOf('actors') === -1 && config.relates.indexOf('actor')+1) {
                                        getData.related('actor', related.actor, config.related.actor.sort, function(movies) {
                                            callback(null, movies);
                                        });
                                    }
                                    else {
                                        callback(null, []);
                                    }
                                },
                                "year": function(callback) {
                                    if (related && related.year && config.relates.indexOf('year')+1) {
                                        getData.related('year', related.year, config.related.year.sort, function(movies) {
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

                    var required = requiredData.movie(type, result.movie, result.movies);
                    var render = mergeData(result, required);

                    renderData(res, type, render, url);

                    if (render && config.cache.full_storage) {
                        memcached.set(
                            urlHash,
                            render,
                            config.cache.time_storage,
                            function (err) {
                                if (err) {
                                    console.log(err);
                                }
                            }
                        );
                    }

                });

        }

    });

});

function renderData(res, type, render, url) {

    if (config.theme == 'skeleton') {
        res.json(render);
    }
    else {
        res.render(type, render);
    }

    console.timeEnd(url);

}


module.exports = router;