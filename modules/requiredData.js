'use strict';

var config = require('../config/config');

function additionalRequiredData(keys, movies, type) {

    var data = {};

    data[type] = movies;

    for (var key in keys) {
        if (keys.hasOwnProperty(key)) {
            keys[key] = '<a href="' + urlData(config.urls[key], keys[key]) + '">' + keys[key] + '</a>';
            data.name = addKeywords(config[type][key].name, keys)
        }
    }

    return data;

}

/* Required data on index page:
 - protocol
 - domain
 - email
 - urls
 - social
 - code
 - title
 - description
 - keywords
 - schema
 */

function indexRequiredData() {

    var data = {};
    
    data.protocol    = config.protocol;
    data.domain      = config.domain;
    data.email       = config.email;
    data.urls        = config.urls;
    data.social      = config.social;
    data.code        = changeCode(config.code);
    
    data.title       = addKeywords(config.titles.index);
    data.description = addKeywords(config.descriptions.index);
    data.keywords    = addKeywords(config.keywords.index);
    data.schema      = (config.schema) ? generalSchemaData(data) : {};

    return data;

}

/* Required data on movie page:
 - protocol
 - domain
 - email
 - urls
 - disqus
 - social
 - code
 - abuse
 - title
 - description
 - keywords
 - schema
 */

function movieRequiredData(key, keys, movies) {

    var data = {};
    
    data.protocol    = config.protocol;
    data.domain      = config.domain;
    data.email       = config.email;
    data.urls        = config.urls;
    data.disqus      = config.disqus;
    data.social      = config.social;
    data.abuse       = config.abuse;
    data.code        = changeCode(config.code);
    
    data.title       = addKeywords(config.titles.movie[key], keys);
    data.description = addKeywords(config.descriptions.movie[key], keys);
    data.keywords    = addKeywords(config.keywords.movie[key], keys);
    data.schema      = (config.schema) ? movieSchemaData(keys, movies) : {};

    return data;

}

/* Required data on category page:
 - protocol
 - domain
 - email
 - urls
 - social
 - code
 - url
 - sort
 - page
 - title
 - description
 - keywords
 - schema
 */

function categoryRequiredData(keys, sort, page, movies) {

    var data = {};
    
    data.protocol = config.protocol;
    data.domain   = config.domain;
    data.email    = config.email;
    data.urls     = config.urls;
    data.social   = config.social;
    data.code     = changeCode(config.code);

    for (var key in keys) {
        if (keys.hasOwnProperty(key)) {

            keys['sort'] = (config.sorting.default != sort)
                ? config.titles.sort[sort] || ''
                : '';
            keys['page'] = (page != 1)
                ? config.titles.num.replace('[num]', page)
                : '';

            data.title       = addKeywords(config.titles[key], keys);
            data.description = addKeywords(config.descriptions[key], keys);
            data.keywords    = addKeywords(config.keywords[key], keys);
            data.url         = urlData(config.urls[key], keys[key]);
            data.sort        = sortUrlData(data.url, sort);
            data.page        = {
                "description" : (config.sorting.default == sort && page == 1) ? 1 : 0,
                "current"     : page,
                "prev"        : pageUrlData(data.url, sort, page, movies.length, 'prev'),
                "next"        : pageUrlData(data.url, sort, page, movies.length, 'next')
            };

        }
    }

    data.schema = (config.schema) ? categorySchemaData(data, movies) : {};

    return data;

}

/* Required data on categories page:
 - protocol
 - domain
 - email
 - urls
 - social
 - code
 - url
 - title
 - description
 - keywords
 - schema
 */

function categoriesRequiredData(key) {

    var data = {};

    var type = {
        "year"     : "years",
        "genre"    : "genres",
        "actor"    : "actors",
        "country"  : "countries",
        "director" : "directors"
    };
    
    data.protocol    = config.protocol;
    data.domain      = config.domain;
    data.email       = config.email;
    data.urls        = config.urls;
    data.social      = config.social;
    data.code        = changeCode(config.code);
    data.url         = categoryUrl(key);

    data.title       = addKeywords(config.titles[type[key]]);
    data.description = addKeywords(config.descriptions[type[key]]);
    data.keywords    = addKeywords(config.keywords[type[key]]);
    data.schema      = (config.schema) ? generalSchemaData(data) : {};

    return data;

}

function urlData(attribute, query) {

    return config.protocol + config.domain + '/' + attribute + '/' + encodeURIComponent(query);

}

function categoryUrl(key) {

    return config.protocol + config.domain + '/' + config.urls[key];

}

function sortUrlData(url, sort) {

    var sortingUp = [
        'kinopoisk-rating-up',
        'imdb-rating-up',
        'kinopoisk-vote-up',
        'imdb-vote-up',
        'year-up',
        'premiere-up'
    ];

    var sortingDown = {
        "kinopoisk-rating-down" : sortingUp[0],
        "imdb-rating-down"      : sortingUp[1],
        "kinopoisk-vote-down"   : sortingUp[2],
        "imdb-vote-down"        : sortingUp[3],
        "year-down"             : sortingUp[4],
        "premiere-down"         : sortingUp[5]
    };

    return sortingUp.map(function(s) {

        var a = false;

        if (sort == s) {
            s = sort.replace('up','down');
            a = 'up';
        }
        else if (sortingDown[sort] == s) {
            a = 'down';
        }

        return {
            "name"   : config.sorting[s],
            "url"    : url + '?sort=' + s,
            "active" : a
        }

    });

}

function pageUrlData(url, sort, page, count, type) {

    if (type == 'prev') {
        return (page - 1) ? url + '/' + (page - 1) + '?sort=' + sort : '';
    }
    else {
        return (count == config.counts.category) ? url + '/' + (page + 1) + '?sort=' + sort : '';
    }

}

function addKeywords(text, keywords) {

    var dflt = true;

    text = text.replace(/&nbsp;/g,' ');

    if (keywords) {
        for (var key in keywords) {
            if (keywords.hasOwnProperty(key)) {

                var keyRegExp = ('' + key).replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
                var keywordRegExp = ('' + keywords[key]).replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');

                var allSpecific = new RegExp('(\\s*\\(\\s*' + keywordRegExp + '\\s*\\)\\s*\\{(.*?)\\}\\s*)', 'gi');
                var match = allSpecific.exec(text);
                if (match) {dflt = false;}
                text = text.replace(allSpecific, ' $2 ');

                var allKeys = new RegExp('\\[' + keyRegExp + '\\]', 'g');
                text = text.replace(allKeys, keywords[key]);

            }
        }
    }

    if (dflt) {
        var defaultSpecific = new RegExp('(\\s*\\(\\s*default\\s*\\)\\s*\\{(.*?)\\}\\s*)', 'gi');
        text = text.replace(defaultSpecific, ' $2 ');
    }

    var allSpecifics = new RegExp('(\\s*\\(.*?\\)\\s*\\{(.*?)\\}\\s*)', 'gi');
    text = text.replace(allSpecifics, ' ');

    text = text.replace(/&nbsp;/gi, ' ');
    text = text.replace(/\s+/g, ' ');
    text = text.replace(/(^\s*)|(\s*)$/g, '');

    while (true) {

        var p = new RegExp('\\[(.*?)\\]', 'g');
        var parts = p.exec(text);

        if (parts) {
            var search = parts[0];
            var part = parts[1].split('|');
            var replace = part[Math.floor(Math.random() * part.length)];
            text = text.replace(search, replace);
        }
        else {

            break;

        }

    }

    return text;

}

function movieSchemaData(movie, movies) {

    if (!movie || !movies) return [];

    var result = [];

    for (var category in movies) {
        if (movies.hasOwnProperty(category)) {

            movies[category].forEach(function(data) {

                var schemaItemList = {};
                schemaItemList['@context'] = 'http://schema.org';
                schemaItemList['@type'] = 'ItemList';
                schemaItemList['name'] = data.name.replace(/<\/?[^>]+(>|$)/g, '');
                schemaItemList['numberOfItems'] = data.related.length;
                schemaItemList['itemListOrder'] = 'Descending';
                schemaItemList['itemListElement'] = [];

                data.related.forEach(function(m, key) {

                    schemaItemList['itemListElement'].push({
                        "@type": "ListItem",
                        "position": key+1,
                        "item": schemaMovie(m)
                    });

                });

                result.push(schemaItemList);

            });

        }
    }

    var schemaBreadcrumbList = {};

    schemaBreadcrumbList['@context'] = 'http://schema.org';
    schemaBreadcrumbList['@type'] = 'BreadcrumbList';
    schemaBreadcrumbList['itemListElement'] = [];

    schemaBreadcrumbList['itemListElement'].push({
        "@type": "ListItem",
        "position": 1,
        "item": {
            "@id": "/",
            "name": "Главная",
            "url":  config.protocol + config.domain
        }
    });

    schemaBreadcrumbList['itemListElement'].push({
        "@type": "ListItem",
        "position": 2,
        "item": {
            "@id": "/" + encodeURIComponent(config.urls.genre) + "/" + encodeURIComponent(movie.genre),
            "name": movie.genre,
            "url": config.protocol + config.domain + "/" + encodeURIComponent(config.urls.genre) + "/" + encodeURIComponent(movie.genre)
        }
    });

    schemaBreadcrumbList['itemListElement'].push({
        "@type": "ListItem",
        "position": 3,
        "item": {
            "@id": movie.url,
            "name": movie.title,
            "url": movie.url
        }
    });

    result.push(schemaMovie(movie));
    result.push(schemaBreadcrumbList);

    return result;

}

function schemaMovie(movie) {

    var schemaMovie = {};

    schemaMovie['@context'] = 'http://schema.org';
    schemaMovie['@type'] = 'Movie';
    schemaMovie['name'] = movie.title_ru;
    schemaMovie['alternativeHeadline'] = movie.title_en;
    schemaMovie['description'] = movie.description;
    schemaMovie['image'] = movie.poster;
    schemaMovie['sameAs'] =  movie.url;
    schemaMovie['url'] =  movie.url;
    schemaMovie['actor'] = [];
    schemaMovie['director'] = [];
    schemaMovie['genre'] = [];
    schemaMovie['aggregateRating'] = (movie.kp_rating || movie.imdb_rating)
        ? {
            "@type": "AggregateRating",
            "bestRating": 10,
            "ratingCount": movie.kp_vote + movie.imdb_vote,
            "ratingValue": Math.round( ( ((movie.kp_rating || movie.imdb_rating)/10 + (movie.imdb_rating || movie.kp_rating)/10) / 2) * 10 ) / 10
        }
        : null;

    if (movie.actors_arr) {
        movie.actors_arr.forEach(function (actor) {
            schemaMovie['actor'].push({
                "@type": "Person",
                "name": actor,
                "sameAs": config.protocol + config.domain + "/" + encodeURIComponent(config.urls.actor) + "/" + encodeURIComponent(actor)
            });
        });
    }

    if (movie.directors_arr) {
        movie.directors_arr.forEach(function (director) {
            schemaMovie['director'].push({
                "@type": "Person",
                "name": director,
                "sameAs": config.protocol + config.domain + "/" + encodeURIComponent(config.urls.director) + "/" + encodeURIComponent(director)
            });
        });
    }

    if (movie.genres_arr) {
        movie.genres_arr.forEach(function (genre) {
            schemaMovie['genre'].push(encodeURIComponent(genre));
        });
    }

    return schemaMovie;

}

function categorySchemaData(data, movies) {

    var result = [];

    var schemaItemList = {};
    var schemaBreadcrumbList = {};

    schemaItemList['@context'] = 'http://schema.org';
    schemaItemList['@type'] = 'ItemList';
    schemaItemList['name'] = data.title;
    schemaItemList['numberOfItems'] = movies.length;
    schemaItemList['itemListOrder'] = 'Descending';
    schemaItemList['itemListElement'] = [];

    movies.forEach(function(movie, key) {

        schemaItemList['itemListElement'].push({
            "@type": "ListItem",
            "position": key+1,
            "item": schemaMovie(movie)
        });

    });

    schemaBreadcrumbList['@context'] = 'http://schema.org';
    schemaBreadcrumbList['@type'] = 'BreadcrumbList';
    schemaBreadcrumbList['itemListElement'] = [];

    schemaBreadcrumbList['itemListElement'].push({
        "@type": "ListItem",
        "position": 1,
        "item": {
            "@id": "/",
            "name": "Главная",
            "url": config.protocol + config.domain
        }
    });

    schemaBreadcrumbList['itemListElement'].push({
        "@type": "ListItem",
        "position": 2,
        "item": {
            "@id": data.url,
            "name": data.title,
            "url": data.url
        }
    });

    result.push(schemaItemList);
    result.push(schemaBreadcrumbList);

    return result;

}

function generalSchemaData(data) {

    var schemaWebSite = {};

    schemaWebSite['@context'] = 'http://schema.org';
    schemaWebSite['@type'] = 'WebSite';
    schemaWebSite['name'] = data.title;
    schemaWebSite['url'] = config.protocol + config.domain;
    schemaWebSite['potentialAction'] = {
        "@type": "SearchAction",
        "target": config.protocol + config.domain + "/" + config.urls.search + "/title?&q={query}",
        "query-input": "required name=query"
    };

    return schemaWebSite;

}

function changeCode(code) {

    for (var key in code) {
        if (code.hasOwnProperty(key)) {
            code[key] = code[key].replace(/&nbsp;/gi,'');
        }
    }

    return code;

}

module.exports = {
    "index"      : indexRequiredData,
    "movie"      : movieRequiredData,
    "category"   : categoryRequiredData,
    "categories" : categoriesRequiredData,
    "additional" : additionalRequiredData
};