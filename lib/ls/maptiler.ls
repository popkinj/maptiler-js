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
    [lon, lat]

  # res: -> 180 / @tileSize / Math.pow(2,it) # Don't know why this is here.
  res: -> @initialResolution / Math.pow(2,it)

  pixelsToMeters: (x,y,z) ->
    [
      (x * @res(z) - @originShift)
      (y * @res(z) - @originShift)
    ]

  metersToPixels: (x,y,z) ->
    px = (x + @originShift) / @res(z)
    py = (y + @originShift) / @res(z)
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

  tileLatLonBounds: (x,y,z) ->
    bounds = @tileBounds x,y,z
    min = @metersToLatLon bounds[0], bounds[1]
    max = @metersToLatLon bounds[2], bounds[3]
    min ++ max

  resolution: (z) -> @initialResolution / Math.pow(2,z)

  zoomForPixelSize: (size) ->
    for i in [0 til 30]
      if size > @resolution(i) and i is not 0 then return i-1

  # Convert TMS tile scheme to Gooogle's
  googleTile: (x,y,z) -> [x,((Math.pow(2,z) - 1) - y)]

  quadTree: (x,y,z) ->
    y = (Math.pow(2,z) - 1) - y
    quadKey = ''
    for i from z til 0 by -1
      digit = 0
      mask = 1 .<<. (i - 1)
      digit += 1 if x is not 0 and x is not 0
      digit += 2 if y is not 0 and y is not 0
    digit

  getTiles: (left,bottom,right,top,zoom) ->
    mercPos1 = @latLonToMeters left,bottom
    mercPos2 = @latLonToMeters right,top
    tilePos1 = @metersToTile mercPos1[0], mercPos1[1], zoom
    tilePos2 = @metersToTile mercPos2[0], mercPos2[1], zoom

    tiles = []
    for ty from tilePos1[1] to tilePos2[1]
      for tx from tilePos1[0] to tilePos2[0]
        google = @googleTile(tx,ty,zoom)
        bounds3857 = @tileBounds(tx,ty,zoom)
        bounds4326 = @tileLatLonBounds(tx,ty,zoom)
        tiles.push {
          tms: [zoom,tx,ty]
          google: [zoom,tx,google[1]]
          extent3857:bounds3857
          extent4326:bounds4326
        }
    tiles

# Export as a module if in node/io
module.exports = maptiler if module?.exports?




### Testing
# This is the bottom of the Bay of Plenty in New Zealand
# b = [[177.13846,-38.03898],[177.26629,-37.99240]]
# tiles = maptiler.getTiles b[0][0], b[0][1], b[1][0], b[1][1], 12
# console.log tiles
# Should spit out the following
# [0:
#   extent3857: [19714638.33531266, -4588667.6820157, 19724422.274933163, -4578883.742395198],
#   extent4326: [177.09960937500003, -38.06539235133247, 177.1875, -37.996162679728116],
#   google: [12, 4063, 2516],
#   tms: [12, 4063, 1579]]
# 1: ...
# 2: ...
# 3: ...
#
