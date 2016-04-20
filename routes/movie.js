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

router.get('/:movie/:type?', function(req, res, next) {

    var url     = decode(config.domain + req.originalUrl);
    var urlHash = md5(url.toLowerCase());
    var id      = getId();
    var type    = getType();

    if (!id) return next({"status": 404, "message": "Not found"});

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

        var related = {};

        async.series({
                "movie": function (callback) {
                    getData.movie(id, function (movie) {
                        if (movie && movie.id) {
                            related = movie;
                            callback(null, movie);
                        }
                        else {
                            callback('Not data!');
                        }
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
                                    getData.additional('country', related.countries, config.related.country.sort, 'related', function (movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "genres": function(callback) {
                                if (related && related.genres && config.relates.indexOf('genres')+1) {
                                    getData.additional('genre', related.genres, config.related.genre.sort, 'related', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "directors": function(callback) {
                                if (related && related.directors && config.relates.indexOf('directors')+1) {
                                    getData.additional('director', related.directors, config.related.director.sort, 'related', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "actors": function(callback) {
                                if (related && related.actors && config.relates.indexOf('actors')+1) {
                                    getData.additional('actor', related.actors, config.related.actor.sort, 'related', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "country": function(callback) {
                                if (related && related.country && config.relates.indexOf('countries') === -1 && config.relates.indexOf('country')+1) {
                                    getData.additional('country', related.country, config.related.country.sort, 'related', function (movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "genre": function(callback) {
                                if (related && related.genre && config.relates.indexOf('genres') === -1 && config.relates.indexOf('genre')+1) {
                                    getData.additional('genre', related.genre, config.related.genre.sort, 'related', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "director": function(callback) {
                                if (related && related.director && config.relates.indexOf('directors') === -1 && config.relates.indexOf('director')+1) {
                                    getData.additional('director', related.director, config.related.director.sort, 'related', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "actor": function(callback) {
                                if (related && related.actor && config.relates.indexOf('actors') === -1 && config.relates.indexOf('actor')+1) {
                                    getData.additional('actor', related.actor, config.related.actor.sort, 'related', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            },
                            "year": function(callback) {
                                if (related && related.year && config.relates.indexOf('year')+1) {
                                    getData.additional('year', related.year, config.related.year.sort, 'related', function(movies) {
                                        callback(null, movies);
                                    });
                                }
                                else {
                                    callback(null, []);
                                }
                            }
                        },
                        function(err, result) {

                            if (err) console.log('[getSphinx] Movies Get Error.', err);

                            callback(null, result);

                        });
                }
            },
            function(err, result) {

                if (err) return next({"status": 404, "message": err});

                var required = requiredData.movie(type, result.movie, result.movies);
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
                res.render(type, render, function(err, html) {
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

    function getId() {

        req.params.movie = '/' + req.params.movie || '';

        var prefix_id  = config.urls.prefix_id || '/';
        var regexpId   = new RegExp(decode(prefix_id) + '([0-9]{1,7})', 'ig');
        var id         = regexpId.exec(decode(req.params.movie)); id = (id) ? parseInt(id[1]) : '';

        return id;

    }

    function getType() {

        req.params.type  = req.params.type || 'single';

        var regexpType = new RegExp('(single|online|trailer|download|picture)', 'ig');
        var type       = regexpType.exec(req.params.type); type = (type) ? type[1] : 'single';

        return type;

    }

});

module.exports = router;