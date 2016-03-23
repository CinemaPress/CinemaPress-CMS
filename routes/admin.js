'use strict';

var config    = require('../config/config');
var memcached = require('../modules/memcached');
var getData   = require('../modules/getData');
var express   = require('express');
var router    = express.Router();
var path      = require('path');
var fs        = require('fs');

router.get('/?', function(req, res) {

    res.render('admin', config);

});

router.post('/movie', function(req, res) {

    if (parseInt(req.body.id)) {

        getData.movie(parseInt(req.body.id), function (movie) {
            if (movie && movie.title) {
                res.json(movie);
            }
            else {
                res.json({"error": "Not found"});
            }
        });

    }
    else {

        res.status(404).send('Not found');

    }

});

router.post('/downgrade', function(req, res) {

    fs.rename(path.join(path.dirname(__dirname), 'config', 'config.js'), path.join(path.dirname(__dirname), 'config', 'config.downgrade.js'), function (err) {
        if (err) {
            res.status(404).send(err);
        }
        fs.rename(path.join(path.dirname(__dirname), 'config', 'config.old.js'), path.join(path.dirname(__dirname), 'config', 'config.js'), function (err) {
            if (err) {
                res.status(404).send(err);
            }
            fs.rename(path.join(path.dirname(__dirname), 'config', 'config.downgrade.js'), path.join(path.dirname(__dirname), 'config', 'config.old.js'), function (err) {
                if (err) {
                    res.status(404).send(err);
                }
                else {
                    res.status(200).send('Downgrade');
                }
            });
        });
    });

});

router.post('/flush', function(req, res) {

    memcached.flush(function(err) {

        if (err) {
            res.status(404).send(err);
        }
        else {
            res.status(200).send('Flush');
        }

    });

});

router.post('/save', function(req, res) {

    req.body.text = config.text;

    if (parseInt(req.body.description.id) && req.body.description.text) {

        var id = parseInt(req.body.description.id);
        var text = br(req.body.description.text);

        if (req.body.text.ids.indexOf(id) == -1) req.body.text.ids.push(id);
        if (text) req.body.text.descriptions[id] = text;

    }

    delete req.body.description;

    req.body.urls.unique_id      = (parseInt(req.body.urls.unique_id) > -298 && parseInt(req.body.urls.unique_id) < 297001) ? parseInt(req.body.urls.unique_id) : 0;
    req.body.cache.time          = parseInt(req.body.cache.time);
    req.body.counts.index        = parseInt(req.body.counts.index);
    req.body.counts.category     = parseInt(req.body.counts.category);
    req.body.counts.top_category = parseInt(req.body.counts.top_category);
    req.body.counts.related      = parseInt(req.body.counts.related);
    req.body.counts.sitemap      = parseInt(req.body.counts.sitemap);
    req.body.top                 = req.body.top.map(function(id) {return parseInt(id);});
    req.body.abuse               = req.body.abuse.map(function(id) {return parseInt(id);});
    req.body.titles              = nbsp(req.body.titles);
    req.body.titles.movie        = nbsp(req.body.titles.movie);
    req.body.descriptions        = nbsp(req.body.descriptions);
    req.body.descriptions.movie  = nbsp(req.body.descriptions.movie);
    req.body.keywords            = nbsp(req.body.keywords);
    req.body.keywords.movie      = nbsp(req.body.keywords.movie);
    req.body.titles.sort         = nbsp(req.body.titles.sort);
    req.body.code.head           = req.body.code.head.replace(/(\n|\r)/g,'&nbsp;');
    req.body.code.footer         = req.body.code.footer.replace(/(\n|\r)/g,'&nbsp;');

    var data = JSON.stringify(req.body);

    fs.writeFile(path.join(path.dirname(__dirname), 'config', 'config.new.js'), 'module.exports = ' + data + ';', function(err) {
        if (err) {
            console.log(err);
            res.status(404).send('Error');
        }
        else {
            fs.rename(path.join(path.dirname(__dirname), 'config', 'config.js'), path.join(path.dirname(__dirname), 'config', 'config.old.js'), function (err) {
                if (err) throw err;
                fs.rename(path.join(path.dirname(__dirname), 'config', 'config.new.js'), path.join(path.dirname(__dirname), 'config', 'config.js'), function (err) {
                    if (err) throw err;
                    res.status(200).send('Save');
                });
            });
        }
    });

});

function nbsp(obj) {

    for (var key in obj) {

        if (obj.hasOwnProperty(key) && typeof obj[key] === 'string') {

            obj[key] = obj[key].replace(/[^0-9A-Za-zА-Яа-яЁё.,;/}«»_!#%№\]\|\[\?\(\)\{\s\+-]/g,'');
            obj[key] = obj[key].replace(/(\n|\r)/g,'&nbsp;');
            obj[key] = obj[key].replace(/\s+/g, ' ');
            obj[key] = obj[key].replace(/(^\s*)|(\s*)$/g, '');

        }

    }

    return obj;

}

function br(text) {

    return text.replace(/(\n|\r)/g,'<br>');

}

module.exports = router;