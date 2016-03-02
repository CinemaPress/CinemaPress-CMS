module.exports = {
    "domain": "example.com",
    "email": "support@example.com",
    "disqus": "films-online",
    "theme": "skeleton",
    "top": [299, 300, 301, 302, 303, 304,305,306],
    "abuse": [462360],
    "social": {
        "vk": "http://vk.com/group",
        "facebook": "http://facebook.com/group",
        "twitter": "http://twitter.com/group"
    },
    "cache": 60 * 60 * 24,
    "counts": {
        "index": 20,
        "category": 30,
        "top_category": 10,
        "related": 5,
        "sitemap": 10000
    },
    "related": "countries,genres,directors,actors,year",
    "titles": {
        "index": "Фильмы онлайн",
        "year" : "Фильмы [year] года [sort] [page]",
        "years" : "Фильмы по годам",
        "genre": "Фильмы в жанре [genre] [sort] [page]",
        "genres" : "Фильмы по жанрам",
        "country": "Фильмы из страны [country] [sort] [page]",
        "countries": "Фильмы по странам",
        "actor": "Фильмы с участием [actor] [sort] [page]",
        "actors": "Самые популярные актеры",
        "director": "Фильмы которые срежессировал [director] [sort] [page]",
        "directors": "Самые популярные режиссеры",
        "type": "[type] онлайн",
        "search": "Поиск фильма [search] [sort] [page]",
        "num": "на странице [num]",
        "movie": {
            "single": "[title_ru]",
            "online": "[title_ru] онлайн",
            "download": "[title_ru] скачать",
            "trailer": "[title_ru] трейлер",
            "picture": "[title_ru] кадры"
        },
        "related": {
            "year": "Фильмы [year] года",
            "genre": "Фильмы в жанре - [genre]",
            "country": "Фильмы из страны - [country]",
            "actor": "Лучшие фильмы актера - [actor]",
            "director": "Лучшие фильмы режиссера - [director]"
        },
        "sort": {
            "kinopoisk-rating-up": "отсортировано по рейтингу КиноПоиска",
            "kinopoisk-rating-down": "отсортировано по рейтингу КиноПоиска",
            "imdb-rating-up": "отсортировано по рейтингу IMDb",
            "imdb-rating-down": "отсортировано по рейтингу IMDb",
            "kinopoisk-vote-up": "отсортировано по популярности на КиноПоиске",
            "kinopoisk-vote-down": "отсортировано по популярности на КиноПоиске",
            "imdb-vote-up": "отсортировано по популярности на IMDb",
            "imdb-vote-down": "отсортировано по популярности на IMDb",
            "year-up": "отсортировано по году",
            "year-down": "отсортировано по году",
            "premiere-up": "отсортировано по дате премьеры",
            "premiere-down": "отсортировано по дате премьеры"
        }
    },
    "descriptions": {
        "index": "Все фильмы",
        "year" : "Фильмы [year] года",
        "years" : "Фильмы по годам",
        "genre": "Фильмы в жанре [genre]",
        "genres" : "Фильмы по жанрам",
        "country": "Фильмы из страны [country]",
        "countries": "Фильмы по странам",
        "actor": "Фильмы с участием [actor]",
        "actors": "Самые популярные актеры",
        "director": "Фильмы которые срежессировал [director]",
        "directors": "Самые популярные режиссеры",
        "type": "[type]",
        "search" : "Поиск фильма [search]",
        "movie": {
            "single": "[title_ru] смотреть онлайн",
            "online": "[title_ru] смотреть онлайн",
            "download": "[title_ru] скачать",
            "trailer": "[title_ru] трейлер",
            "picture": "[title_ru] кадры"
        }
    },
    "keywords": {
        "index": "Все фильмы",
        "year" : "Фильмы [year] года",
        "years" : "Фильмы по годам",
        "genre": "Фильмы в жанре [genre]",
        "genres" : "Фильмы по жанрам",
        "country": "Фильмы из страны [country]",
        "countries": "Фильмы по странам",
        "actor": "Фильмы с участием [actor]",
        "actors": "Самые популярные актеры",
        "director": "Фильмы которые срежессировал [director]",
        "directors": "Самые популярные режиссеры",
        "type": "[type]",
        "search" : "Поиск фильма [search]",
        "movie": {
            "single": "[title_ru] смотреть онлайн",
            "online": "[title_ru] смотреть онлайн",
            "download": "[title_ru] скачать",
            "trailer": "[title_ru] трейлер",
            "picture": "[title_ru] кадры"
        }
    },
    "sorting": {
        "kinopoisk-rating-up": "По рейтингу КП",
        "kinopoisk-rating-down": "По рейтингу КП",
        "imdb-rating-up": "По рейтингу IMDb",
        "imdb-rating-down": "По рейтингу IMDb",
        "kinopoisk-vote-up": "По популярности КП",
        "kinopoisk-vote-down": "По популярности КП",
        "imdb-vote-up": "По популярности IMDb",
        "imdb-vote-down": "По популярности IMDb",
        "year-up": "По году",
        "year-down": "По году",
        "premiere-up": "По дате премьеры",
        "premiere-down": "По дате премьеры",
        "default": "kinopoisk-vote-up"
    },
    "urls": {
        "prefix_id": "id",
        "separator": "-",
        "movie_url": "[prefix_id][separator][title_ru][separator][title_en]",
        "movie": "movie",
        "year" : "year",
        "genre": "genre",
        "country": "country",
        "actor": "actor",
        "director": "director",
        "type": "type",
        "search" : "search",
        "sitemap" : "sitemap"
    }
};