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

    var url = decodeURIComponent((config.domain + req.originalUrl).toLowerCase());
    var urlHash = md5(url);
    console.time(url);

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

            async.series({
                    "premieres": function (callback) {
                        getData.movies({}, 'premiere-up', 1, 'index', function (movies) {
                            callback(null, movies);
                        });
                    },
                    "bests": function (callback) {
                        getData.movies({}, 'imdb-vote-up', 1, 'index', function (movies) {
                            callback(null, movies);
                        });
                    },
                    "year": function (callback) {
                        getData.movies({"year": new Date().getFullYear()}, 'kinopoisk-vote-up', 1, 'index', function (movies) {
                            callback(null, movies);
                        });
                    },
                    "top": function (callback) {
                        getData.top(function (movies) {
                            callback(null, movies);
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

});

module.exports = router;