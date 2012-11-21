Iterator = require './iterator'

exports.iterator = (arr) ->
  new Iterator(arr)