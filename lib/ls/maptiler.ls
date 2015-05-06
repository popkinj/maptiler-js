maptiler =
  originShift: 2 * Math.PI * 6378137 / 2.0
  tileSize: 256

  latLonToMeters: (lon, lat) ->
    mx = lon * @originShift / 180.0
    my = Math.log( Math.tan((90 + lat) * Math.PI / 360.0 )) /
      (Math.PI / 180.0)
    my = my * @originShift / 180.0
    [mx, my]

  metersToLatLon: (x, y) ->
    lon = (x / @originShift) * 180.0
    lat = (y / @originShift) * 180.0
    lat =
      180 / Math.PI *
      (
        2 * Math.atan( Math.exp( lat * Math.PI / 180.0)) -
        Math.PI / 2.0
      )
    [lat, lon]

  res: -> 180 / tileSize / Math.pow(2,it)

  pixelsToMeters: (x,y,z) ->
    [(px * @res(z) - @originShift), (py * @res(z) - @originShift)]

console.log maptiler.latLonToMeters -123, 52
console.log maptiler.metersToLatLon -13692297.367572648, 6800125.454397306
