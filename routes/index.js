'use strict';

var getData      = require('../modules/getData');
var requiredData = require('../modules/requiredData');
var mergeData    = require('../modules/mergeData');
var config       = require('../config/config');
var express      = require('express');
var async        = require('async');
var router       = express.Router();

router.get('/', function(req, res) {

    var time = decodeURIComponent(req.originalUrl);
    console.time(time);

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

            console.timeEnd(time);

        });

});

module.exports = router;