stash = {}
originShift = 2 * Math.pi * 6378137 / 2.0
tileSize = 256

stash.latLonToMeters = (lon, lat) ->
  mx = lon * originShift / 180.0
  my = Math.log( Math.tan((90 + lat) * Math.pi / 360.0 )) / (Math.pi / 180.0)
  my = my * originShift / 180.0
  mx, my

stash.metersToLatLon = (lon, lat) ->
  lon = (mx / originShift) * 180.0
  lat = (my / originShift) * 180.0

  lat = 180 / Math.pi * (2 * Math.atan( Math.exp( lat * Math.pi / 180.0)) - Math.pi / 2.0)
  lat, lon

res -> 180 / tileSize / Math.pow(2,it)

stash.pixelsToMeters = (x,y,z) ->
  (px * res(z) - originShift), (py * res(z) - originShift)
