'use strict';

var config       = require('./config/config');
var cookieParser = require('cookie-parser');
var bodyParser   = require('body-parser');
var express      = require('express');
var path         = require('path');
var app          = express();

var robots       = require(__dirname + '/routes/robots');
var sitemap      = require(__dirname + '/routes/sitemap');
var categories   = require(__dirname + '/routes/categories');
var movie        = require(__dirname + '/routes/movie');
var admin        = require(__dirname + '/routes/admin');
var index        = require(__dirname + '/routes/index');

var port = process.env.PORT || parseInt(config.nginx.addr.split(':')[1]) || 3000;

app.set('views', [
    path.join(__dirname, 'themes', 'skeleton', 'views'),
    path.join(__dirname, 'themes', config.theme, 'views')
]);
app.set('view engine', 'jade');

app.use(cookieParser());
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.use('/' + config.urls.year, categories);
app.use('/' + config.urls.genre, categories);
app.use('/' + config.urls.country, categories);
app.use('/' + config.urls.actor, categories);
app.use('/' + config.urls.director, categories);
app.use('/' + config.urls.type, categories);
app.use('/' + config.urls.search, categories);
app.use('/' + config.urls.movie, movie);
app.use('/' + config.urls.sitemap, sitemap);
app.use('/' + config.urls.admin, admin);
app.use('/robots.txt', robots);
app.use('/', index);

app.use(function(err, req, res, next) {
    err.status = (err.status) ? err.status : 404;
    err.message = (err.message) ? err.message : 'Not Found';
    res.status(err.status).render('error', {
        "status": err.status,
        "message": err.message
    });
});

app.use(function(req, res) {
    res.status(404).render('error', {
        "status": 404,
        "message": 'Not Found'
    });
});

app.listen(port);