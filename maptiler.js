var maptiler;
maptiler = {
  redis: {
    on: false,
    turnOn: function(){
      var redis;
      redis = require('redis').createClient();
      redis.del('maptiler');
      redis.quit();
      this.on = true;
    },
    turnOff: function(){
      this.on = false;
    }
  },
  originShift: 2 * Math.PI * 6378137 / 2.0,
  tileSize: 256,
  initialResolution: 2 * Math.PI * 6378137 / 256,
  latLonToMeters: function(lon, lat){
    var x, y;
    x = lon * this.originShift / 180.0;
    y = Math.log(Math.tan((90 + lat) * Math.PI / 360.0)) / (Math.PI / 180.0);
    y = y * this.originShift / 180.0;
    return [x, y];
  },
  metersToLatLon: function(x, y){
    var lon, lat;
    lon = (x / this.originShift) * 180.0;
    lat = (y / this.originShift) * 180.0;
    lat = 180 / Math.PI * (2 * Math.atan(Math.exp(lat * Math.PI / 180.0)) - Math.PI / 2.0);
    return [lon, lat];
  },
  res: function(it){
    return this.initialResolution / Math.pow(2, it);
  },
  pixelsToMeters: function(x, y, z){
    return [x * this.res(z) - this.originShift, y * this.res(z) - this.originShift];
  },
  metersToPixels: function(x, y, z){
    var px, py;
    px = (x + this.originShift) / this.res(z);
    py = (y + this.originShift) / this.res(z);
    return [(x + this.originShift) / this.res(z), (y + this.originShift) / this.res(z)];
  },
  pixelsToTile: function(x, y){
    return [~~(Math.ceil(x / this.tileSize) - 1), ~~(Math.ceil(y / this.tileSize) - 1)];
  },
  pixelsToRaster: function(x, y, z){
    return [x, (this.tileSize << z) - y];
  },
  metersToTile: function(x, y, z){
    var pos;
    pos = this.metersToPixels(x, y, z);
    return this.pixelsToTile(pos[0], pos[1]);
  },
  tileBounds: function(x, y, z){
    var min, max;
    min = this.pixelsToMeters(x * this.tileSize, y * this.tileSize, z);
    max = this.pixelsToMeters((x + 1) * this.tileSize, (y + 1) * this.tileSize, z);
    return [min[0], min[1], max[0], max[1]];
  },
  tileLatLonBounds: function(x, y, z){
    var bounds, min, max;
    bounds = this.tileBounds(x, y, z);
    min = this.metersToLatLon(bounds[0], bounds[1]);
    max = this.metersToLatLon(bounds[2], bounds[3]);
    return min.concat(max);
  },
  resolution: function(z){
    return this.initialResolution / Math.pow(2, z);
  },
  zoomForPixelSize: function(size){
    var i$, ref$, len$, i;
    for (i$ = 0, len$ = (ref$ = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]).length; i$ < len$; ++i$) {
      i = ref$[i$];
      if (size > this.resolution(i) && i !== 0) {
        return i - 1;
      }
    }
  },
  googleTile: function(x, y, z){
    return [x, (Math.pow(2, z) - 1) - y];
  },
  quadTree: function(x, y, z){
    var quadKey, i$, i, digit, mask;
    y = (Math.pow(2, z) - 1) - y;
    quadKey = '';
    for (i$ = z; i$ > 0; --i$) {
      i = i$;
      digit = 0;
      mask = 1 << i - 1;
      if (x !== 0 && x !== 0) {
        digit += 1;
      }
      if (y !== 0 && y !== 0) {
        digit += 2;
      }
    }
    return digit;
  },
  getTiles: function(left, bottom, right, top, zoom, tileCallback){
    var async, mercPos1, mercPos2, tilePos1, tilePos2, redis, tiles, tx, testX, addTile, ty, testY, doRow, done, this$ = this;
    async = require('async');
    mercPos1 = this.latLonToMeters(left, bottom);
    mercPos2 = this.latLonToMeters(right, top);
    tilePos1 = this.metersToTile(mercPos1[0], mercPos1[1], zoom);
    tilePos2 = this.metersToTile(mercPos2[0], mercPos2[1], zoom);
    if (this.redis.on) {
      redis = require('redis').createClient();
      redis.on('error', function(it){
        return Console.log("Error with Redis: " + it);
      });
    } else {
      tiles = [];
    }
    tx = tilePos1[0];
    testX = function(){
      return tx > tilePos2[0];
    };
    addTile = function(callbackX){
      var google, bounds3857, bounds4326, meta;
      google = this$.googleTile(tx, ty, zoom);
      bounds3857 = this$.tileBounds(tx, ty, zoom);
      bounds4326 = this$.tileLatLonBounds(tx, ty, zoom);
      meta = {
        tms: [zoom, tx, ty],
        google: [zoom, tx, google[1]],
        extent3857: bounds3857,
        extent4326: bounds4326
      };
      if (this$.redis.on) {
        return redis.rpush('maptiler', meta, function(){
          ++tx;
          return callbackX(null);
        });
      } else {
        tiles.push(meta);
        ++tx;
        return setTimeout(callbackX, 1);
      }
    };
    ty = tilePos1[1];
    testY = function(){
      return ty > tilePos2[1];
    };
    doRow = function(callbackY){
      async.until(testX, addTile, function(){
        ty++;
        tx = tilePos1[0];
        return callbackY(null);
      });
    };
    done = function(){
      if (this$.redis.on) {
        redis.quit();
        tileCallback('maptiler');
      } else {
        tileCallback(tiles);
      }
    };
    return async.until(testY, doRow, done);
  }
};
if ((typeof module != 'undefined' && module !== null ? module.exports : void 8) != null) {
  module.exports = maptiler;
}