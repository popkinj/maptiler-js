maptiler =
  originShift: 2 * Math.PI * 6378137 / 2.0
  tileSize: 256
  initialResolution: 2 * Math.PI * 6378137 / 256

  latLonToMeters: (lon, lat) ->
    x = lon * @originShift / 180.0
    y = Math.log( Math.tan((90 + lat) * Math.PI / 360.0 )) /
      (Math.PI / 180.0)
    y = y * @originShift / 180.0
    [x, y]

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

  res: -> 180 / @tileSize / Math.pow(2,it)

  pixelsToMeters: (x,y,z) ->
    [
      (px * @res(z) - @originShift)
      (py * @res(z) - @originShift)
    ]

  metersToPixels: (x,y,z) ->
    [
      (x + @originShift) / @res(z)
      (y + @originShift) / @res(z)
    ]

  pixelsToTile: (x,y) ->
    [
      ~~(Math.ceil(x / @tileSize) - 1)
      ~~(Math.ceil(y / @tileSize) - 1)
    ]

  pixelsToRaster: (x,y,z) -> [ x, (@tileSize .<<. z) - y ]

  metersToTile: (x,y,z) ->
    pos = @metersToPixels(x,y,z)
    @pixelsToTile pos[0], pos[1]

  tileBounds: (x,y,z) ->
    min = @pixelsToMeters x * @tileSize, y * @tileSize, z
    max = @pixelsToMeters (x + 1) * @tileSize, (y + 1) * @tileSize, z
    [min[0],min[1],max[0],max[1]]

  resolution: (z) -> @initialResolution / Math.pow(2,z)

  zoomForPixelSize: (size) ->
    for i in [0 til 30]
      if size > @resolution(i) and i is not 0 then return i-1

  # Convert TMS tile scheme to Gooogle's
  googleTile: (x,y,z) -> [x,(Math.pow(2,z) - y)]

  quadTree: (x,y,z) ->
    y = (Math.pow(2,z) - 1) - y
# XXX: Check to make sure I should use 'to' and not 'til'
    for i from z to 0 by -1
      console.log i




# Should equal -13692297.3675727 6800125.45439731. Taken from testing postgis
# console.log maptiler.latLonToMeters -123, 52
#
# console.log maptiler.metersToLatLon -13692297.367572648, 6800125.454397306
# console.log maptiler.metersToTile -13692297.367572648, 6800125.454397306, 15
# console.log maptiler.zoomForPixelSize 4
maptiler.quadTree(1,1,7)
# console.log 0 to 30
