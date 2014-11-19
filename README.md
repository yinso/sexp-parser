# Sexp-Parser - parsing symbolic expression.

## Install

    npm install sexp-parser

## Usage

    var sexp = require('sexp-parser');
    sexp.parse('1'); // ==> [ 1 ]
    sexp.parse('(abc (def 1 2 "test"))') // ==> [ {symbo: 'abc'}, [ {symbol: 'def'}, 1, 2, 'test' ]]

Symbols are represented as an object with the key `symbol` mapped to the name of the symbol.

List are represented as Javascript array.

