'use strict';

var Entities = require('html-entities').AllHtmlEntities;
var entities = new Entities();

function decode(str) {
    var out = '', arr, i = 0, l, x;
    str = entities.decode(str);
    arr = str.split(/(%(?:D0|D1)%.{2})/);
    for ( l = arr.length; i < l; i++ ) {
        try {
            x = decodeURIComponent( arr[i] );
        } catch (e) {
            x = arr[i];
        }
        out += x;
    }
    return out.replace(/\+/g, ' ');
}

module.exports = decode;