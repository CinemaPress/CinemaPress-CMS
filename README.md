[![Gitter](https://badges.gitter.im/CinemaPress/CinemaPress-CMS.svg)](https://gitter.im/CinemaPress/CinemaPress-CMS?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=body_badge) [![Slack](https://img.shields.io/badge/cinemapress.slack.com-%D1%87%D0%B0%D1%82-red.svg?style=flat)](https://cinemapress.slack.com/)

# CinemaPress CMS
 :movie_camera: Система управления самообновляемым онлайн кинотеатром.

## Установка:

- <a href="https://cinemapress.org/pokuraem-domen.html" target="_blank">Как купить домен?</a>
- <a href="https://cinemapress.org/pokupaem-VPS.html" target="_blank">Как купить и подключиться к серверу?</a>

Работает на Debian 7 «Wheezy» (64-bit), Debian 8 «Jessie» (64-bit)
```
~# wget cinemapress.org/i -q && chmod +x i && ./i
```

###### Видео установки (готовый кино-сайт за 4 минуты 43 сек):

<a href="https://www.youtube.com/watch?v=lnxw8F8nL-g" target="_blank"><img src="https://raw.githubusercontent.com/CinemaPress/CinemaPress.github.io/master/images/admin/install_player.png" width="600" alt="Готовый кино-сайт за 5 минут (видео)"/></a>

## Обновление:

Обновление **CinemaPress CMS** до последней версии в репозитории.
```
~# wget cinemapress.org/i -q && chmod +x i && ./i 2
```

###### Видео обновления

<a href="https://www.youtube.com/watch?v=KF9OkH3BqPM" target="_blank"><img src="https://raw.githubusercontent.com/CinemaPress/CinemaPress.github.io/master/images/admin/update_player.png" width="600" alt="Обновление CinemaPress CMS"/></a>

## Мониторинг работы сайта

**CinemaPress CMS** использует менеджер процессов ``PM2``, поэтому чтобы отслеживать работоспособность сайта, Вы можете использовать <a href="https://app.keymetrics.io">keymetrics</a>.

- регистрируетесь;
- создаете ``New bucket``;
- получаете ключи;
- соединяетесь с сервером командами:

```
~# pm2 link [secret key] [public key] CinemaPress
~# pm2 install pm2-server-monit
```

<img src="https://raw.githubusercontent.com/CinemaPress/CinemaPress.github.io/master/images/admin/pm2.png" width="600" alt="Обновление CinemaPress CMS"/>

## Распределение нагрузки

Если Ваш сайт стал достаточно посещаемым, то для распределения нагрузки, можно вынести некоторые пакеты на отдельные сервера.

###### Установка CinemaPress CMS сервера:

```
~# wget cinemapress.org/i -q && chmod +x i && ./i 5
```

###### Установка Sphinx сервера:

```
~# wget cinemapress.org/i -q && chmod +x i && ./i 6
```

###### Установка Memcached сервера:

```
~# wget cinemapress.org/i -q && chmod +x i && ./i 7
```

# CinemaPress DataBase
 :minidisc: База данных ~ **500 000 фильмов/сериалов** (все фильмы/сериалы планеты).
 
## Импорт:
После успешного запуска **CinemaPress CMS**, можете [приобрести](https://cinemapress.org/) и импортировать полную базу данных.
```
~# wget cinemapress.org/i -q && chmod +x i && ./i 4
```

###### Видео импорта базы данных CinemaPress

<a href="https://www.youtube.com/watch?v=wJGJf86beDU" target="_blank"><img src="https://raw.githubusercontent.com/CinemaPress/CinemaPress.github.io/master/images/admin/db_player.png" width="600" alt="Импорт CinemaPress DataBase"/></a>

# CinemaPress Themes

- [Barney (kinogo.co)](https://github.com/CinemaPress/Theme-Barney)
```
~# wget cinemapress.org/i -q && chmod +x i && ./i 3
```
<a href="https://github.com/CinemaPress/Theme-Barney"><img src="https://raw.githubusercontent.com/CinemaPress/Theme-Barney/master/screenshot.jpg" width="400"></a>
---
- [Ted (kinogb.net)](https://github.com/CinemaPress/Theme-Ted)
```
~# wget cinemapress.org/i -q && chmod +x i && ./i 3
```
<a href="https://github.com/CinemaPress/Theme-Ted"><img src="https://raw.githubusercontent.com/CinemaPress/Theme-Ted/master/screenshot.jpg" width="400"></a>
---
- [Lily (kinokong.net)](https://github.com/CinemaPress/Theme-Lily)
```
~# wget cinemapress.org/i -q && chmod +x i && ./i 3
```
<a href="https://github.com/CinemaPress/Theme-Lily"><img src="https://raw.githubusercontent.com/CinemaPress/Theme-Lily/master/screenshot.jpg" width="400"></a>
---
- [Marshall (zerx.co)](https://github.com/CinemaPress/Theme-Marshall)
```
~# wget cinemapress.org/i -q && chmod +x i && ./i 3
```
<a href="https://github.com/CinemaPress/Theme-Marshall"><img src="https://raw.githubusercontent.com/CinemaPress/Theme-Marshall/master/screenshot.jpg" width="400"></a>
---
# Кейс по созданию онлайн кинотеатра
Описания всех этапов создания кино-сайта на CinemaPress CMS.

<a href="https://github.com/CinemaPress/CinemaPress-CMS/wiki/%D0%9A%D0%B5%D0%B9%D1%81-%D0%BF%D0%BE-%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D1%8E-%D0%BE%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD-%D0%BA%D0%B8%D0%BD%D0%BE%D1%82%D0%B5%D0%B0%D1%82%D1%80%D0%B0"><img src="https://raw.githubusercontent.com/CinemaPress/CinemaPress.github.io/master/images/admin/case.png"></a>

# Что такое CinemaPress CMS?
Это система управления самообновляемым кино-сайтом, которая строится на данных **CinemaPress DataBase** и работает на ``NodeJS (ExpressJS) + Sphinx + Memcached``.

![Admin page CinemaPress CMS](https://raw.githubusercontent.com/CinemaPress/CinemaPress.github.io/master/images/admin/screen.png)

- **Сохранить** - сохраняет все изменения которые были сделаны в админ панели;
- **Откатиться** - возвращается на ``одно!`` сохранение назад, к примеру если Вы сделали изменение в админ панели, зашли на сайт и что-то изменилось в худшую сторону, то просто откатитесь на предыдущую версию конфигурации;
- **Очистить кэш** - любое изменение и сохранение в админ панели нужно сопровождать очисткой кэша (если кэширование включено), иначе Вы не увидите изменений на сайте;
- **Помощь** - ссылка на документацию CinemaPress CMS;
- **Карандаш** - позволяет изменять стандартные описания к фильмам.

# Основное
- **Протокол** - основной протокол сайта https или http;
- **Домен** - доменное имя Вашего сайта, например «``example.com``»;
- **Email** - электронная почта для связи с администрацией сайта;
- **Disqus** - Ваш ``shortname``.disqus.com на сайте [disqus](https://disqus.com/admin/create/), требуется для того, чтобы Вы через свой аккаунт могли модерировать комментарии Ваших пользователей;
- **Тема** - название темы оформления, должно быть с точности таким как называется папка с темой в дирректории ``themes``.

# Главная страница

Формирования фильмов на главной странице из различных категорий и сортировок.

- **Типы**
    + **Название** - Название категории, можно использовать ключ ``[type]``;
    + **Сортировка** - Сортировка фильмов;
    + **Типы** - Типы, которые перечисляются через запятую, можно использовать такие типы ``фильмы``, ``сериалы``, ``мультфильмы``, ``аниме``, ``тв-передачи``.
- **Страны**
    + **Название** - Название категории, можно использовать ключ ``[country]``;
    + **Сортировка** - Сортировка фильмов;
    + **Страны** - Страны, которые перечисляются через запятую, можно использовать названия стран в именительном падеже ``Россия``, ``США``, ``Франция``, ``Индия``, ``СССР``, и др.
- **Жанры**
    + **Название** - Название категории, можно использовать ключ ``[genre]``;
    + **Сортировка** - Сортировка фильмов;
    + **Жанры** - Жанры, которые перечисляются через запятую, можно использовать названия жанров в именительном падеже ``комедия``, ``ужасы``, ``история``, ``спорт``, ``драма``, и др.
- **Режиссеры**
    + **Название** - Название категории, можно использовать ключ ``[director]``;
    + **Сортировка** - Сортировка фильмов;
    + **Режиссеры** - Режиссеры, которые перечисляются через запятую, можно использовать имена режиссеров в именительном падеже ``Дэвид Финчер``, ``Ф. Гэри Грей``, ``Джонатан Демме``, и др.
- **Актеры**
    + **Название** - Название категории, можно использовать ключ ``[actor]``;
    + **Сортировка** - Сортировка фильмов;
    + **Актеры** - Актеры, которые перечисляются через запятую, можно использовать имена актеров в именительном падеже ``Джоди Фостер``, ``Том Круз``, ``Леонардо ДиКаприо``, и др.
- **Годы**
    + **Название** - Название категории, можно использовать ключ ``[year]``;
    + **Сортировка** - Сортировка фильмов;
    + **Годы** - Годы, которые перечисляются через запятую ``2007``, ``2016``, ``1994``, и др.

# Параметры URL
- **Страница фильма** - Как будет выглядеть URL страница фильма;
   + **Разделитель** - будет подставлено в URL на месте ``[separator]``;
   + **Префикс перед ID** - будет подставлено в URL перед ID «``id299``» (по умолчанию «``id``»);
   + **Уникальный ID** - принимает значение от ``-297`` до ``297000``, требуется для того, чтобы ID фильмов в URL на сайте не совпадали с ID КиноПоиск (по умолчанию ``0``, ID такие-же как на КиноПоиске).

```
По умолчанию: http://example.com/movie/id299-matrica-the-matrix

Доступные параметры:
[prefix_id] - обязательный праметр, отображает ID фильма, например «id299»;
[separator] - разделитель между параметрами, например «-»;
[title_ru] - русское название, например «Матрица»;
[title_en] - оригинальное название, например «The Matrix»;
[genre] - жанр фильма, например «комедия»;
[country] - страна фильма, например «США»;
[year] - год фильма, например «2016»;
[actor] - главный актер, например «Том Круз»;
[director] - режиссер, например «Тим Бертон».
```

- **URL фильма** - Как будет выглядеть URL страница фильма;

```
Например: http://example.com/movie/id299-matrica-the-matrix
```

- **URL года** - Как будет выглядеть URL страница года;

```
Например: http://example.com/year/2016
```

- **URL жанра** - Как будет выглядеть URL страница жанра;

```
Например: http://example.com/genre/комедия
```

- **URL страны** - Как будет выглядеть URL страница страны;

```
Например: http://example.com/country/США
```

- **URL актера** - Как будет выглядеть URL страница актера;

```
Например: http://example.com/actor/Том Круз
```

- **URL режиссера** - Как будет выглядеть URL страница режиссера;

```
Например: http://example.com/director/Тим Бертон
```

- **URL типа** - Как будет выглядеть URL страница типа;

```
Например: http://example.com/type/Сериалы
```

- **URL поиска** - Как будет выглядеть URL страница поиска;

```
Например: http://example.com/search/Аватар
```

- **URL карты сайта** - Как будет выглядеть URL страница карты сайта;

```
Например: http://example.com/sitemap
```

- **URL админ панели** - Должен начинаться с **admin**-``secret-key``, вместо ``secret-key`` любое секретное слово;

```
Например: http://example.com/admin-idiot
```

#### URL типов
- **URL фильмов** - Как будет выглядеть URL каталога фильмов;

```
Например: http://example.com/type/фильмы
```

- **URL сериалов** - Как будет выглядеть URL каталога сериалов;

```
Например: http://example.com/type/сериалы
```

- **URL мультфильмов** - Как будет выглядеть URL каталога мультфильмов;

```
Например: http://example.com/type/мультфильмы
```

- **URL тв-передач** - Как будет выглядеть URL каталога тв-передач;

```
Например: http://example.com/type/тв-передачи
```

- **URL аниме** - Как будет выглядеть URL каталога аниме;

```
Например: http://example.com/type/аниме
```

# Топ фильмы

![Top movies CinemaPress CMS](https://raw.githubusercontent.com/CinemaPress/CinemaPress.github.io/master/images/admin/top.png)

- **ID** - ID фильмов (ID КиноПоиск) которые будут отображаться в «карусели фильмов» вверху (если это поддерживает тема оформления).

```
Например: 299,300,301,302
```

# Скрыть фильмы
- **ID** - ID фильмов (ID КиноПоиск) на которые поступили жалобы от правообладателей и требуется ограничить их скачивание и онлайн просмотр.

```
Например: 299,300,301,302
```

# Числовые параметры
- **Nginx** - адрес по которому Nginx слушает сайт (не изменяется и носит исключительно информативный характер);
- **Кэширование** - Кэширует каждую страницу сайта на заданное время, чтобы не нагружать Sphinx ресурсоёмкими запросами;
    - Время кэширования;
    - Кэш можно вынести на отдельный сервер, просто укажите адрес этого сервера.
- **Сфинкс** - Адрес сервера Sphinx, можно сделать отдельный сервер для Sphinx;
- **Статика** - По умолчанию все картинки грузятся с КиноПоиск (``st.cinemapress.org``), Вы можете перенести все статические файлы на свой сервер или создать CNAME-запись ``st.kp.yandex.net`` или ``st.kinopoisk.ru`` в DNS домена и показывать картинки через свой адрес;
- **Микроразметка** - включение или отключение микроразметки Schema.org на сайте;
- **Rocket режим** - позволяет получить в <a href="https://developers.google.com/speed/pagespeed/insights/">Google PageSpeed Insights</a> показатели в ``90-100%`` за счет использования на сайте картинок минимального размера.

![Rocket mode CinemaPress CMS](https://raw.githubusercontent.com/CinemaPress/CinemaPress.github.io/master/images/admin/pagespeed.png)

#### Публикация
- **Опубликовать сразу**
    - диапазон ID КиноПоиск которые нужно сразу опубликовать на сайте;
    - фильмы, для которых написано авторское описание, будут публиковаться на сайте даже если не входят в диапазон.
- **Отложено публиковать** - каждый час исходный диапазон опубликованных фильмов будет расширяться в равной степени в большую и меньшую сторону;
- **Обязательно наличие** - информация которая должна присутствовать в каждом опубликованном фильме на сайте.

#### Фильмов на странице
- **Главная** - Число фильмов на главной странице (в каждой категории «Фильмы года», «Новинки», и т.д.);
- **Категория** - Число фильмов в категориях;
- **Топ в категории** - Число топовых фильмов в категории, в большинстве шаблонах, вставляются в «карусель фильмов» в категории;
- **Связанные фильмы** - Число связанных фильмов в каждой категории, которые отображаются на странице фильма;
- **Карта сайта** - Число фильмов в карте сайта в каждом году.

# Связанные фильмы

![Related movies CinemaPress CMS](https://raw.githubusercontent.com/CinemaPress/CinemaPress.github.io/master/images/admin/related.png)

- **Страны** - Отображать связанные фильмы по всем странам оригинального фильма, одной стране или не отображать;
- **Жанры** - Отображать связанные фильмы по всем жанрам оригинального фильма, одному жанру или не отображать;
- **Актеры** - Отображать связанные фильмы по всем актерам оригинального фильма, одному актеру или не отображать;
- **Режиссеры** - Отображать связанные фильмы по всем режиссерам оригинального фильма, одному режиссеру или не отображать;
- **Год** - Отображать связанные фильмы по году или не отображать.

#### Сортировка и названия связанных категорий
- **Связанные фильмы по году** - можно использовать ключ ``[year]``, куда будет подставлен год связанных фильмов;
- **Связанные фильмы по жанру** - можно использовать ключ ``[genre]``, куда будет подставлен жанр связанных фильмов;
- **Связанные фильмы по стране** - можно использовать ключ ``[country]``, куда будет подставлена страна связанных фильмов;
- **Связанные фильмы по актеру** - можно использовать ключ ``[actor]``, куда будет подставлено имя актера связанных фильмов;
- **Связанные фильмы по режиссеру** - можно использовать ключ ``[director]``, куда будет подставлено имя режиссера связанных фильмов;

# Параметры названий, описаний, ключевых слов

##### [Что такое «синонимация»?](https://github.com/CinemaPress/CinemaPress-CMS/wiki/%D0%A7%D1%82%D0%BE-%D1%82%D0%B0%D0%BA%D0%BE%D0%B5-%C2%AB%D1%81%D0%B8%D0%BD%D0%BE%D0%BD%D0%B8%D0%BC%D0%B0%D1%86%D0%B8%D1%8F%C2%BB-%D0%B2-CinemaPress-CMS%3F)
##### [Как написать текст для определенного фильма, жанра, страны, года, актера, режиссера?](https://github.com/CinemaPress/CinemaPress-CMS/wiki/%D0%9A%D0%B0%D0%BA-%D0%BD%D0%B0%D0%BF%D0%B8%D1%81%D0%B0%D1%82%D1%8C-%D1%82%D0%B5%D0%BA%D1%81%D1%82-%D0%B4%D0%BB%D1%8F-%D0%BE%D0%BF%D1%80%D0%B5%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%BD%D0%BE%D0%B3%D0%BE-%D1%84%D0%B8%D0%BB%D1%8C%D0%BC%D0%B0,-%D0%B6%D0%B0%D0%BD%D1%80%D0%B0,-%D1%81%D1%82%D1%80%D0%B0%D0%BD%D1%8B,-%D0%B3%D0%BE%D0%B4%D0%B0,-%D0%B0%D0%BA%D1%82%D0%B5%D1%80%D0%B0,-%D1%80%D0%B5%D0%B6%D0%B8%D1%81%D1%81%D0%B5%D1%80%D0%B0%3F)

- **Главная** - Можно использовать «синонимацию»;
- **Категория - год** - Можно использовать «синонимацию», текст для определенного года и ключи:

```
[year] - год текущей категории, на сайте отобразится например, как «2016»;
[sort] - название сортировки;
[page] - текст и номер страницы при переходе.
```

- **Категория - годы** - Можно использовать «синонимацию»;
- **Категория - жанр** - Можно использовать «синонимацию», текст для определенного жанра и ключи:

```
[genre] - жанр текущей категории, на сайте отобразится например, как «комедия»;
[sort] - название сортировки;
[page] - текст и номер страницы при переходе.
```

- **Категория - жанры** - Можно использовать «синонимацию»;
- **Категория - страна** - Можно использовать «синонимацию», текст для определенной страны и ключи:

```
[country] - страна текущей категории, на сайте отобразится например, как «Россия»;
[sort] - название сортировки;
[page] - текст и номер страницы при переходе.
```

- **Категория - страны** - Можно использовать «синонимацию»;
- **Категория - актер** - Можно использовать «синонимацию», текст для определенного актера и ключи:

```
[actor] - актер текущей категории, на сайте отобразится например, как «Том Круз»;
[sort] - название сортировки;
[page] - текст и номер страницы при переходе.
```

- **Категория - актеры** - Можно использовать «синонимацию»;
- **Категория - режиссер** - Можно использовать «синонимацию», текст для определенного режиссера и ключи:

```
[director] - режиссер текущей категории, на сайте отобразится например, как «Тим Бертон»;
[sort] - название сортировки;
[page] - текст и номер страницы при переходе.
```

- **Категория - режиссеры** - Можно использовать «синонимацию»;
- **Категория - тип** - Можно использовать «синонимацию», текст для определенного типа и ключи:

```
[type] - тип текущей категории, на сайте отобразится например, как «Сериалы»;
[sort] - название сортировки;
[page] - текст и номер страницы при переходе.
```
- **Страница поиска** - Можно использовать «синонимацию», текст для определенного поискового запроса и ключи:

```
[search] - поисковый запрос пользователя, на сайте отобразится например, как «Аватар»;
[sort] - название сортировки;
[page] - текст и номер страницы при переходе.
```

## На странице фильма
Везде можно использовать «синонимацию», текст для определенного фильма и ключи:

```
[id] - ID фильма, например «299»;
[title] - название фильма, например «Аватар / Avatar»;
[title_ru] - русское название фильма, например «Аватар»;
[title_en] - оригинальное фильма, например «Avatar»;
[description] - стандартное описание фильма;
[year] - год фильма, например «2016»;
[countries] - страны фильма через запятую, например «США,Япония»;
[country] - одна из стран фильма, например «США»;
[genres] - жанры фильма через запятую, например «комедия,драма»;
[genre] - один из жанров фильма, например «комедия»;
[actors] - актеры фильма через запятую, например «Том Круз,Бред Питт»;
[actor] - один из актеров фильма, например «Бред Питт»;
[directors] - режиссеры фильма через запятую, например «Стивен Брилл,Питер Фаррелли»;
[director] - один из режиссеров фильма, например «Стивен Брилл»;
[premiere] - дата премьеры фильма, например «2016-02-12»;
```

# Имена сортировок
- **Сортировка по умолчанию** - сортировка по умолчанию для всех категорий.

# Аккаунты соц. сетей
- **ВКонтакте** - URL страницы ВКонтакте;
- **facebook** - URL страницы facebook;
- **twitter** - URL страницы twitter.

# Вставить код
- **Верх страницы** - код будет добавлен в ``<head>`` сайта, подходит для подтверждения и т.д.;
- **Низ страницы** - код будет добавлен перед ``</body>`` сайта, подходит для вставки рекламных скриптов и т.д.;
- **Файл robots.txt** - записи для поисковых систем.