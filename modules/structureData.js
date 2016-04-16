'use strict';

var config  = require('../config/config');
var getSlug = require('speakingurl');

function categoriesData(movies) {

    var categories = {};
    categories.max = 1;

    movies.forEach(function(movie) {

        var category = ('' + movie.category).split(',');

        category.forEach(function(c) {

            categories[c] = (categories[c]) ? categories[c]+1 : 1;

            if (categories[c] > categories.max) {
                categories.max = categories[c];
            }

        });

    });

    return categories;

}

function moviesData(movies) {

    return movies.map(function(movie) {

        var id = parseInt(movie.kp_id) + parseInt(config.urls.unique_id);

        var poster      = config.protocol + config.st + '/images/film_iphone/iphone360_' + movie.kp_id + '.jpg';
        var poster_big  = config.protocol + config.st + '/images/film_big/' + movie.kp_id + '.jpg';
        var poster_min  = config.protocol + config.st + '/images/sm_film/' + movie.kp_id + '.jpg';
        var picture     = poster;
        var picture_big = poster_big;
        var picture_min = poster_min;
        var pictures    = [];

        if (movie.pictures) {
            var p = movie.pictures.split(',');
            var r = Math.floor(Math.random() * p.length);
            if (p[r] > 363866) {
                picture     = config.protocol + config.st + '/images/kadr/' + p[r] + '.jpg';
                picture_big = config.protocol + config.st + '/images/kadr/' + p[r] + '.jpg';
                picture_min = config.protocol + config.st + '/images/kadr/sm_' + p[r] + '.jpg';
            }
            pictures    = p.map(function(id) {
                if (id > 363866) {
                    return config.protocol + config.st + '/images/kadr/' + id + '.jpg';
                }
            });
        }

        return {
            "id"            : id,
            "kp_id"         : movie.kp_id,
            "title"         : movie.search,
            "poster"        : (config.rocket) ? poster_min : poster,
            "poster_big"    : poster_big,
            "poster_min"    : poster_min,
            "picture"       : picture,
            "picture_big"   : picture_big,
            "picture_min"   : picture_min,
            "pictures"      : pictures,
            "title_ru"      : movie.title_ru || movie.title_en,
            "title_en"      : movie.title_en,
            "description"   : uniqueDescription(movie.kp_id) || movie.description,
            "year"          : movie.year,
            "year_url"      : createCategoryUrl('year', movie.year),
            "countries"     : (movie.country == '_empty')  ? '' : randPos(movie.country),
            "directors"     : (movie.director == '_empty') ? '' : randPos(movie.director),
            "genres"        : (movie.genre == '_empty')    ? '' : randPos(movie.genre),
            "actors"        : (movie.actor == '_empty')    ? '' : randPos(movie.actor),
            "country"       : (movie.country == '_empty')  ? '' : movie.country.split(',')[0],
            "director"      : (movie.director == '_empty') ? '' : movie.director.split(',')[0],
            "genre"         : (movie.genre == '_empty')    ? '' : movie.genre.split(',')[0],
            "actor"         : (movie.actor == '_empty')    ? '' : movie.actor.split(',')[0],
            "countries_url" : (movie.country == '_empty')  ? '' : randPos(createCategoryUrl('country', movie.country)),
            "directors_url" : (movie.director == '_empty') ? '' : randPos(createCategoryUrl('director', movie.director)),
            "genres_url"    : (movie.genre == '_empty')    ? '' : randPos(createCategoryUrl('genre', movie.genre)),
            "actors_url"    : (movie.actor == '_empty')    ? '' : randPos(createCategoryUrl('actor', movie.actor)),
            "country_url"   : (movie.country == '_empty')  ? '' : createCategoryUrl('country', movie.country.split(',')[0]),
            "director_url"  : (movie.director == '_empty') ? '' : createCategoryUrl('director', movie.director.split(',')[0]),
            "genre_url"     : (movie.genre == '_empty')    ? '' : createCategoryUrl('genre', movie.genre.split(',')[0]),
            "actor_url"     : (movie.actor == '_empty')    ? '' : createCategoryUrl('actor', movie.actor.split(',')[0]),
            "countries_arr" : (movie.country == '_empty')  ? [] : movie.country.split(','),
            "directors_arr" : (movie.director == '_empty') ? [] : movie.director.split(','),
            "genres_arr"    : (movie.genre == '_empty')    ? [] : movie.genre.split(','),
            "actors_arr"    : (movie.actor == '_empty')    ? [] : movie.actor.split(','),
            "kp_rating"     : movie.kp_rating,
            "kp_vote"       : movie.kp_vote,
            "imdb_rating"   : movie.imdb_rating,
            "imdb_vote"     : movie.imdb_vote,
            "premiere"      : toDate(movie.premiere),
            "type"          : movie.type,
            "url"           : createMovieUrl(id, {
                "title_ru"  : movie.title_ru,
                "title_en"  : movie.title_en,
                "year"      : movie.year,
                "country"   : (movie.country == '_empty')   ? '' : movie.country.split(',')[0],
                "director"  : (movie.director == '_empty')  ? '' : movie.director.split(',')[0],
                "genre"     : (movie.genre == '_empty')     ? '' : movie.genre.split(',')[0],
                "actor"     : (movie.actor == '_empty')     ? '' : movie.actor.split(',')[0]
            })
        }

    });

}

function randPos(items) {

    var itemsArr = shuffle(('' + items).split(','));
    if (itemsArr.length > 1) {
        var lastArr = itemsArr.pop();
        items = (itemsArr.join(', ')) + ' и ' + lastArr;
    }
    else {
        items = itemsArr.join(', ');
    }

    return items;

}

function shuffle(array) {
    var currentIndex = array.length, temporaryValue, randomIndex;

    while (0 !== currentIndex) {

        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex -= 1;

        temporaryValue = array[currentIndex];
        array[currentIndex] = array[randomIndex];
        array[randomIndex] = temporaryValue;
    }

    return array;
}

function uniqueDescription(id) {

    if (config.text.ids.indexOf(id)+1) {

        return config.text.descriptions[id];

    }
    else {

        return null;

    }

}

function createMovieUrl(id, data) {

    var separator = config.urls.separator;
    var prefix_id = config.urls.prefix_id + '' + id;
    var url = config.urls.movie_url;

    url = url.replace(/\[prefix_id]/g, prefix_id);
    url = url.replace(/\[separator]/g, separator);

    for (var key in data) {
        if (data.hasOwnProperty(key)) {
            if (!data[key]) {
                url = url.replace(separator + '[' + key + ']' + separator, separator);
                url = url.replace('[' + key + ']' + separator, '');
                url = url.replace(separator + '[' + key + ']', '');
            }
            else {
                url = url.replace('[' + key + ']', getSlug(data[key], separator));
            }
        }
    }

    return 'http://' + config.domain + '/' + config.urls.movie + '/' + url;

}

function createCategoryUrl(type, items) {

    var itemsArr = ('' + items).split(',');

    itemsArr = itemsArr.map(function(item) {

        return '<a href="' + config.protocol + config.domain + '/' + config.urls[type] + '/' + encodeURIComponent(item) +'">' + item +'</a>';

    });

    return itemsArr.join(', ');

}

function toDate(days) {
    days = (days - 719528) * 1000 * 60 * 60 * 24;
    return new Date(days).toJSON().substr(0, 10);
}

module.exports = {
    "categories" : categoriesData,
    "movies"     : moviesData
};