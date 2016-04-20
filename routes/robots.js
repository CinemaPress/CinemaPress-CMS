'use strict';

var config  = require('../config/config');
var express = require('express');
var router  = express.Router();

router.get('/?', function(req, res) {

    res.type('text/plain');
    res.send(
        config.code.robots + '\n\n' +
        'Host: ' + config.domain + '\n\n' +
        'Sitemap: ' + config.protocol + config.domain + '/' + config.urls.sitemap
    );

});

module.exports = router;