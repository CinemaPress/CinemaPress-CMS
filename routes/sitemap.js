'use strict';

var getData = require('../modules/getData');
var config  = require('../config/config');
var express = require('express');
var router  = express.Router();

router.get('/:year?', function(req, res) {

    var year = (req.params.year)
        ? parseInt(req.params.year)
        : '';

    if (year) {

        getData.movies({"year": year}, 'premiere-up', 1, 'sitemap', function(movies) {
            res.header('Content-Type', 'application/xml');
            res.render('sitemap', {
                "domain" : config.domain,
                "urls"   : config.urls,
                "movies" : movies
            });
        });

    }
    else {

        res.header('Content-Type', 'application/xml');
        res.render('sitemap', {
            "domain" : config.domain,
            "urls"   : config.urls
        });

    }

});

module.exports = router;