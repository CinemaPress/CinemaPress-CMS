'use strict';

var config  = require('../config/default/config');
var getData = require('./getData');
var path    = require('path');
var fs      = require('fs');

if (config.publish.every.hours && config.publish.every.movies) {

    getData.publish(function (ids) {

        if (!ids) {
            console.log('[publish] Not Movies.');
            config.publish.every.hours = 0;
            config.publish.every.movies = 0;
        }
        else if (ids.start_id == config.publish.start && ids.stop_id == config.publish.stop) {
            console.log('[publish] All movies published.');
            config.publish.every.hours = 0;
            config.publish.every.movies = 0;
        }
        else {
            console.log('[publish] New IDs: ' + ids.start_id + ' - ' + ids.stop_id);
            config.publish.start = ids.start_id;
            config.publish.stop = ids.stop_id;
        }

        var data = JSON.stringify(config);

        fs.writeFile(path.join(path.dirname(__dirname), 'config', 'config.new.js'), 'module.exports = ' + data + ';', function(err) {
            if (err) return console.log(err);
            fs.rename(path.join(path.dirname(__dirname), 'config', 'config.js'), path.join(path.dirname(__dirname), 'config', 'config.old.js'), function (err) {
                if (err) console.log(err);
                fs.rename(path.join(path.dirname(__dirname), 'config', 'config.new.js'), path.join(path.dirname(__dirname), 'config', 'config.js'), function (err) {
                    if (err) console.log(err);
                });
            });
        });

    });

}