time = require('microtime').nowDouble
Iterator = require('../lib/iterator')
require 'should'
Future = require 'fibers/future'

shouldRunInParallel = (fn, expectedTime) ->
  start = time()
  fn()
  (time() - start).should.be.within(expectedTime - 0.01, expectedTime + 0.01)

sleep = (duration) ->
  f = new Future()
  setTimeout ->
    f.return()
  , duration
  f.wait()

describe 'Iterator', ->

  beforeEach ->
    @values = [0,1,2]
    @iterator = new Iterator(@values)

  describe 'map', ->

    it 'should apply fn to each value', ->
      @iterator.map((v) -> v * 2).toA().should.eql([0, 2, 4])

    it 'should run in parallel', ->
      shouldRunInParallel =>
        @iterator.map (v) -> sleep(50)
      , 0.05

  describe 'each', ->
    it 'should run in parallel', ->
      shouldRunInParallel =>
        @iterator.each (v) -> sleep(50)
      , 0.05

  describe 'first', ->
    it 'should only return first values', ->
      @iterator.first(((v) -> v), 2).toA().should.eql([0,1])

    it "should only take as long as fastest 'first' functions to return", ->      
      shouldRunInParallel =>
        @iterator.first (v, i) ->
          if i < 1
            sleep(50)
          else
            sleep(1000)
      , 0.05