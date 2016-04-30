'use strict';

var memcached     = require('../modules/memcached');
var config        = require('../config/config');
var structureData = require('./structureData');
var requiredData  = require('./requiredData');
var sphinx        = require('./sphinx');
var async         = require('async');
var md5           = require('md5');

var bests_db = 'bests_' + config.domain.replace(/[^A-Za-z0-9]/g,'_');
var movies_db = 'movies_' + config.domain.replace(/[^A-Za-z0-9]/g,'_');

function getCategories(category, callback) {

    var text = (config.publish.text && config.text.ids.length)
        ? ' OR kp_id = ' + config.text.ids.join(' OR kp_id = ') + ' '
        : ' ';

    var where = (config.publish.required.split(',')).map(function(ctgry) {
        if (ctgry) {
            return '`' + ctgry.trim() + '` != \'\'';
        }
    });
    where = (where.length) ? ' AND ' + where.join(' AND ') : '';

    var queryString = '' +
        ' SELECT ' +
            category + ' AS category, ' +
            '(' +
                '(' +
                    'kp_id >= ' + config.publish.start +
                        ' AND ' +
                    'kp_id <= ' + config.publish.stop +
                ')' + text +
            ') AS movie' +
        ' FROM ' + bests_db +
        ' WHERE ' +
            ' MATCH(\'@all_movies _all_ @' + category + ' !_empty\') ' +
            ' AND movie > 0 ' +
            where +
        ' ORDER BY kp_vote DESC ' +
        ' LIMIT 10000 ' +
        ' OPTION max_matches = 10000';

    sphinx(queryString, function (err, movies) {

        if (err) console.log('[getCategories] Sphinx Get Error:', err);

        var categories = [];

        if (movies && movies.length) {
            categories = structureData.categories(movies);
        }

        callback(categories);

    });

}

function getMovies(query, sort, page, type, callback) {

    var limit = config.counts[type];
    var start = page * config.counts[type] - config.counts[type];
    var max   = start + limit;

    var text = (config.publish.text && config.text.ids.length)
        ? ' OR kp_id = ' + config.text.ids.join(' OR kp_id = ') + ' '
        : ' ';

    var where = (config.publish.required.split(',')).map(function(ctgry) {
        if (ctgry) {
            return '`' + ctgry.trim() + '` != \'\'';
        }
    });
    where = (where.length) ? ' AND ' + where.join(' AND ') : '';

    var queryString = '' +
        ' SELECT *, ' +
            '(' +
                '(' +
                    'kp_id >= ' + config.publish.start +
                        ' AND ' +
                    'kp_id <= ' + config.publish.stop +
                ')' + text +
            ') AS movie' +
        ' FROM ' + movies_db +
        ' WHERE ' +
            createQuery(query, sort) +
            ' AND movie > 0 ' +
            where +
        ' ORDER BY ' + orderBy(sort) +
        ' LIMIT ' + start + ', ' + limit +
        ' OPTION max_matches = ' + max;

    sphinx(queryString, function (err, movies) {

        if (err) console.log('[getMovies] Sphinx Get Error.', err);

        if (movies && movies.length) {
            movies = structureData.movies(movies);
        }
        else {
            movies = [];
        }

        callback(movies);

    });

}

function getPublishMovies(callback) {

    var start_limit = Math.ceil((config.publish.every.movies/config.publish.every.hours)/2);
    var stop_limit = Math.floor((config.publish.every.movies/config.publish.every.hours)/2);

    var startQueryString = '' +
        ' SELECT kp_id' +
        ' FROM ' + movies_db +
        ' WHERE kp_id < ' + config.publish.start +
        ' ORDER BY kp_id DESC' +
        ' LIMIT ' + start_limit +
        ' OPTION max_matches = ' + start_limit;

    var stopQueryString = '' +
        ' SELECT kp_id' +
        ' FROM ' + movies_db +
        ' WHERE kp_id > ' + config.publish.stop +
        ' ORDER BY kp_id ASC' +
        ' LIMIT ' + stop_limit +
        ' OPTION max_matches = ' + stop_limit;

    var queryString = startQueryString + '; ' + stopQueryString;

    sphinx(queryString, function (err, result) {

        if (err) console.log('[getPublishMovies] Sphinx Get Error.', err);

        if (result && result.length) {

            var ids = {};
            var i;

            ids.start_id = config.publish.start;
            ids.stop_id = config.publish.stop;

            for (i = 0; i < result[0].length; i++) {
                ids.start_id = (result[0][i].kp_id < ids.start_id)
                    ? result[0][i].kp_id
                    : ids.start_id;
            }

            for (i = 0; i < result[1].length; i++) {
                ids.stop_id = (result[1][i].kp_id > ids.stop_id)
                    ? result[1][i].kp_id
                    : ids.stop_id;
            }

            callback(ids);

        }
        else {

            callback(null);

        }

    });

}

function getMovie(id, callback) {

    var admin_id = id;

    id = parseInt(id) - parseInt(config.urls.unique_id);

    var range = (id >= config.publish.start && id <= config.publish.stop);
    var text = (config.publish.text && config.text.ids.indexOf(id)+1);
    var admin = ('' + admin_id).indexOf('admin')+1;

    var where = (config.publish.required.split(',')).map(function(ctgry) {
        if (ctgry) {
            return '`' + ctgry.trim() + '` != \'\'';
        }
    });
    where = (where.length) ? ' AND ' + where.join(' AND ') : '';

    if (range || text || admin) {
        var queryString = '' +
            ' SELECT * ' +
            ' FROM ' + movies_db +
            ' WHERE kp_id = ' + id + where +
            ' LIMIT 1 ' +
            ' OPTION max_matches = 1';

        sphinx(queryString, function (err, movies) {

            if (err) console.log('[getMovie] Sphinx Get Error.', err);

            var movie = [];

            if (movies && movies.length) {
                movie = structureData.movies(movies)[0];
            }

            callback(movie);

        });
    }
    else {
        return callback([]);
    }

}

function getAdditionalMovies(attribute, categories, sort, type, callback) {

    var m = [];

    categories = ('' + categories).split(',');

    async.forEachOfSeries(categories, function (category, key, callback) {

        var query = {};
        query[attribute] = (category.replace(/\s+/g, ' ')).replace(/(^\s*)|(\s*)$/g, '');

        getMovies(query, sort, 1, type, function(movies) {

            if (movies && movies.length) {
                m.push(requiredData.additional(query, movies, type));
            }

            callback(null);

        });

    }, function (err) {

        if (err) console.log('[getAdditionalMovies] Get Error.', err);

        callback(m);

    });

}

function getTopMovies(callback) {

    var hash = md5(config.top.join(','));

    if (config.cache.time) {

        memcached.get(hash, function (err, render) {

            if (err) console.log('[getTopMovies] Memcached Get Error:', err);

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
    else {

        getSphinx(function (render) {
            callback(render);
        });

    }
    
    function getSphinx(callback) {

        var m = [];

        async.forEachOfSeries(config.top, function (id, key, callback) {

            id = parseInt(id) + parseInt(config.urls.unique_id);

            getMovie(id, function(movie) {

                if (movie && movie.id) {
                    m.push(movie);
                }

                callback(null);

            });

        }, function (err) {

            if (err) console.log('[getTopMovies] Sphinx Get Error.', err);

            callback(m);

            if (config.cache.time && m) {
                memcached.set(
                    hash,
                    m,
                    config.cache.time,
                    function (err) {
                        if (err) console.log('[getTopMovies] Memcached Set Error.', err);
                    }
                );
            }

        });
        
    }

}

function createQuery(query, sort) {

    var where = [];
    var match = [];

    match.push('');

    if (sort.indexOf('kinopoisk-rating') + 1) {
        where.push('`kp_vote` > 2000');
    }
    else if (sort.indexOf('imdb-rating') + 1) {
        where.push('`imdb_vote` > 2000');
    }
    else if (sort.indexOf('year') + 1 || sort.indexOf('premiere') + 1) {
        where.push('`premiere` <= ' + toDays());
    }

    for (var attribute in query) {
        if (query.hasOwnProperty(attribute)) {

            var search = ('' + query[attribute]).toLowerCase();
            search = search.replace(/[^0-9A-Za-zА-Яа-яЁё\s\+-]/g,'');
            search = search.replace(/\s+/g, ' ');
            search = search.replace(/(^\s*)|(\s*)$/g, '');

            if (attribute == 'type') {
                if (search == config.urls.types.serial) {
                    where.push('`type` = 1');
                    match.push('@all_movies _all_ @genre !аниме !короткометражка');
                }
                else if (search == config.urls.types.mult) {
                    where.push('`type` != 1');
                    match.push('@genre мультфильм | детский !аниме !короткометражка');
                }
                else if (search == config.urls.types.anime) {
                    match.push('@genre аниме');
                }
                else if (search == config.urls.types.tv) {
                    match.push('@genre ток-шоу | новости | реальное | церемония | концерт');
                }
                else if (search = config.urls.types.movie) {
                    where.push('`type` != 1');
                    match.push('@all_movies _all_ @genre !мультфильм');
                }
                else {
                    match.push('@all_movies _all_');
                }
            }
            else {
                match.push('@' + attribute + ' ' + search);
            }

        }
    }

    where.push('MATCH(\'' + match.join(' ').trim() + '\')');

    return where.join(' AND ');

}

function orderBy(sort) {

    var ob;

    switch (sort) {
        case ('kinopoisk-rating-up'):
            ob = 'kp_rating DESC';
            break;
        case ('kinopoisk-rating-down'):
            ob = 'kp_rating ASC';
            break;
        case ('imdb-rating-up'):
            ob = 'imdb_rating DESC';
            break;
        case ('imdb-rating-down'):
            ob = 'imdb_rating ASC';
            break;
        case ('kinopoisk-vote-up'):
            ob = 'kp_vote DESC';
            break;
        case ('kinopoisk-vote-down'):
            ob = 'kp_vote ASC';
            break;
        case ('imdb-vote-up'):
            ob = 'imdb_vote DESC';
            break;
        case ('imdb-vote-down'):
            ob = 'imdb_vote ASC';
            break;
        case ('year-up'):
            ob = 'year DESC';
            break;
        case ('year-down'):
            ob = 'year ASC';
            break;
        case ('premiere-up'):
            ob = 'premiere DESC';
            break;
        case ('premiere-down'):
            ob = 'premiere ASC';
            break;
        default:
            ob = 'kp_vote DESC';
            break;
    }

    return ob;

}

function toDays() {
    return 719527 + Math.floor(new Date().getTime()/(1000*60*60*24));
}

module.exports = {
    "categories" : getCategories,
    "movies"     : getMovies,
    "movie"      : getMovie,
    "additional" : getAdditionalMovies,
    "top"        : getTopMovies,
    "publish"    : getPublishMovies
};