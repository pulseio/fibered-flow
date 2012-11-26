time = require('microtime').nowDouble
Iterator = require('../lib/iterator')
require 'should'
Future = require 'fibers/future'

shouldRunIn = (fn, expectedTime) ->
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
      shouldRunIn =>
        @iterator.map (v) -> sleep(50)
      , 0.05

    describe 'with concurrency', ->

      it 'should limit number of parallel operations to concurrency', ->
        shouldRunIn =>
          @iterator.map(((v) -> sleep(50)), {concurrency: 1})
        , 0.15

  describe 'quickestN', ->
    it 'should only return quickest n values', ->
      @iterator.quickestN(((v) -> v), 2).toA().should.eql([0,1])

    it "should only take as long as fastest 'n' functions to return", ->      
      shouldRunIn =>
        @iterator.quickestN (v, i) ->
          if i < 1
            sleep(50)
          else
            sleep(1000)
      , 0.05

  describe 'quickest', ->
    it 'should return the quickest value', ->
      quickest = @iterator.quickest (v, i) =>
        if i == @iterator.toA().length - 1
          sleep(50)          
        else
          sleep(1000)
        i
          
      quickest.should.eql @iterator.toA()[@iterator.toA().length - 1]