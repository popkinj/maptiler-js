# maptiler-js
Calculate tiles required for a given geographic extent. The coordinates are based on Global Mercator *EPSG:3857* and made to work with existing web mapping libraries like [Openlayers](http://openlayers.org/), [Leaflet](http://leafletjs.com/), [MapboxGL](https://www.mapbox.com/blog/mapbox-gl-js/), [d3](http://d3js.org/) etc..

Pass a geographic extent and zoom level (0-30). Coordinates must be Latitudes and Longitudes.
```javascript
var tiles = maptiler.getTiles(177.13846,-38.03898,177.26629,-37.99240,12);
```
Think of extent as the *left*, *bottom*, *right* and *top* sides of a box.

An object is returned representing an array of all tiles making up the extent at that particular zoom level. The extent arrays can be used to clip the source dataset. The tms/google arrays are how you save the file within the directory structure... And how the files are located by most mapping frameworks.
```javascript
[0:
  extent3857: [19714638.33531266, -4588667.6820157, 19724422.274933163, -4578883.742395198],
  extent4326: [177.09960937500003, -38.06539235133247, 177.1875, -37.996162679728116],
  google: [12, 4063, 2516],
  tms: [12, 4063, 1579]]
1: ...
2: ...
3: ...

```

The rest is up to you. ☺

## Redis Support
Node/io has a hard limit for memory usage. Which can be exceeded when calculating millions of tiles. I personally found anything over 800,000 caused a core dump. This can be overcome by using a memory cache store like [Redis](http://redis.io/). Just make sure you have it installed. Along with a node client like [node-redis](https://github.com/mranney/node_redis).
```javascript
redis = require("redis");
maptiler = require("maptiler-js");

maptiler.redis.turnOn(); // Use Redis

printFirstTile = function (tiles) {
  redis.lpop(tiles, function (tile) {
    console.log(tile);
  });
}
The variable *tiles* is just the object store name in Redis that was allocated by maptiler.

maptiler.getTiles(177.13846,-38.03898,177.26629,-37.99240,12,printFirstTile);
```

Or if you have a small amout of tiles you can allow them to be stored in a regular javascript array.
```javascript
printFirstTile = function (tiles) {
  console.log(tiles);
}

maptiler.getTiles(177.13846,-38.03898,177.26629,-37.99240,12,printAllTile);
```

Most logic was ported from the [maptiler](http://www.maptiler.org/google-maps-coordinates-tile-bounds-projection/) python module. Adapted for node/io or the browser. Redis functionality is limited to server side.
