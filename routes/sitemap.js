'use strict';

var getData = require('../modules/getData');
var config  = require('../config/config');
var md5     = require('md5');
var express = require('express');
var router  = express.Router();

router.get('/:year?', function(req, res) {

    var year = (req.params.year)
        ? parseInt(req.params.year)
        : '';

    var url = decodeURIComponent(config.domain + req.originalUrl);
    var urlHash = md5(url.toLowerCase());
    console.time(url);

    if (year) {

        if (config.cache.time) {

            memcached.get(urlHash, function (err, movies) {

                if (err) throw err;

                if (movies) {

                    res.header('Content-Type', 'application/xml');
                    res.render('sitemap', {
                        "domain": config.domain,
                        "urls": config.urls,
                        "movies": movies
                    });
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

    }
    else {

        res.header('Content-Type', 'application/xml');
        res.render('sitemap', {
            "domain" : config.domain,
            "urls"   : config.urls
        });

        console.timeEnd(url);

    }

    function run() {

        getData.movies({"year": year}, 'premiere-up', 1, 'sitemap', function (movies) {
            res.header('Content-Type', 'application/xml');
            res.render('sitemap', {
                "domain": config.domain,
                "urls": config.urls,
                "movies": movies
            });

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

});

module.exports = router;