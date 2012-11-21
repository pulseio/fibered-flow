# Fibered Flow

Provides parallel flow constructs for fiber based node.js code.

## Quick Example

```javascript
var flow = require('fibered-flow');
var Future = require('fibers/future');

// All of these files will be read in parallel
var contents = flow.map(['file1', 'file2', 'file3']).map({function(f){
    var future = new Future();
    fs.readFile(f, 'utf8', function(contents){
        future.return(contents);
    });
    return future.wait();
}).toA();
```

## Iterators

### map(fn) - Run in parallel

Run a mapping function over all the items in an iterator, running each
operation in parallel, and completing when all the function calls have
finished.  Each invocation of fn runs in its own fiber.  Note: If you
call out to an async function, make sure you block the fiber either by
yielding or waiting on a future.

```javascript
var http = require('fibered-http');
var websites = ['http://foo.bar', 'http://hello.word']

// All the downloads will happen in parallel on separate fibers
var results = flow.iterator(websites).map(function(site){
    // Download website
    return(http.request({url: site}).body)    
}).values();
```

### quickest(fn) - get first result

Run a mapping function over all the items in an iterator, but unlike
map, and return the quickest result to come back.

```javascript
var quickest = flow.iterator(['google.com', 'foo.com']).quickest(function(site){
    ping(site)
    return site;
});
```

### quickestN(fn, n = 1) - Like quickest, but instead gets the fastest n results

```javascript
var quickest = flow.iterator(['google.com', 'foo.com', 'hello.com'], 2).quickest(function(site){
    ping(site)
    return site;
}).toA();
```



#### toA() - Converting from iterator to array

```javascript
    
    flow.iterator(values).map(function(){
        //do something
    }).toA();
    
```
