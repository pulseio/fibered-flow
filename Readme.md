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

### Run in parallel

#### map(fn)

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

### Get first result

## first(fn, x = 1)

Run a mapping function over all the items in an iterator, but unlike
map, the resulting collection will only contain the first 'first' items

```javascript
var fastest = flow.iterator(['google.com', 'foo.com']).first(function(site){
    ping(site)
    return site;
});

```

### Converting from iterator to array

#### toA()

```javascript
    
    flow.iterator(values).map(function(){//do something}).toA();
    
```
