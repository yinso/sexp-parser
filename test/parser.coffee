sexp = require '../src/main'
assert = require 'assert'

describe 'can parse', () ->
  
  canParse = (exp, expected) ->
    it "can parse #{exp}", (done) ->
      actual = sexp.parse exp
      assert.deepEqual expected, actual
      done null
  
  canParse '1', [ 1 ]
  canParse 'hello', [ {symbol: 'hello'}]
  canParse '(hello)', [ [{symbol: 'hello'}]]
  canParse '(hello (world 1 2 "test"))', [ [{symbol: 'hello'}, [ {symbol: 'world'}, 1, 2, "test" ]]]
  