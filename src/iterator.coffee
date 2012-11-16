Future = require 'fibers/future'
util = require 'util'

module.exports = class Iterator

  constructor: (@values, @options = {}) ->
    
  futurize: (fn, args...) ->
    future = new Future()
    Fiber =>
      future.return fn(args...)
    .run()
    future

  # Returns another iterator with the values that result in applying the mapping function.
  # Each application runs in its own fiber, i.e. everything runs in parallel.
  map: (fn) ->
    futures = (@futurize(fn, v, i) for v, i in @values)
    new Iterator(f.wait() for f in futures)

  # Like map, but returns original iterator
  each: (fn) ->
    futures = (@futurize(fn, v, i) for v, i in @values)
    f.wait() for f in futures
    @

  # Maps fn over values, but returns as soon as 'first' results are back
  first: (fn, first = 1) ->
    futures = (new Future() for f in [0...first])
    fibers = []

    # Return results in the order they come back
    for v, i in @values
      do (v, i) ->
        fiber = Fiber ->
          res = fn(v, i)
          for f in futures
            unless f.isResolved()        
              f.return(res)
              break              
        fiber.run()
        fibers.push(fiber)

    # Wait for 'first' results
    results = 
      for i in [0...first]
        futures[i].wait()

    new Iterator(results)

  toA: ->
    @values

  