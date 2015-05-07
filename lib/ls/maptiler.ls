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

  # res: -> 180 / @tileSize / Math.pow(2,it) # Don't know why this is here.
  res: -> @initialResolution / Math.pow(2,it)

  pixelsToMeters: (x,y,z) ->
    [
      (px * @res(z) - @originShift)
      (py * @res(z) - @originShift)
    ]

  metersToPixels: (x,y,z) ->
    px = (x + @originShift) / @res(z)
    py = (y + @originShift) / @res(z)
    # console.log "px: #px  py: #py"
    # console.log "z: #z"
    # console.log "@res: #{@res(z)}"
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
    # console.log "mx #{mercPos1[0]}"
    # console.log "my #{mercPos1[1]}"
    # console.log mercPos1
    mercPos2 = @latLonToMeters right,top
    # console.log mercPos2
    tilePos1 = @metersToTile mercPos1[0], mercPos1[1], zoom
    # console.log tilePos1
    tilePos2 = @metersToTile mercPos2[0], mercPos2[1], zoom
    # console.log tilePos2

    tiles = []
    for ty from tilePos1[1] to tilePos2[1]
      for tx from tilePos1[0] to tilePos2[0]
        google = @googleTile(tx,ty,zoom)
        tiles.push {
          tms: [zoom,tx,ty]
          google: [zoom,tx,google[1]]
        }
    # console.log "done"
    #   console.log ty
    console.log tiles



# Should equal -13692297.3675727 6800125.45439731. Taken from testing postgis
# console.log maptiler.latLonToMeters -123, 52
#
# console.log maptiler.metersToLatLon -13692297.367572648, 6800125.454397306
# console.log maptiler.metersToTile -13692297.367572648, 6800125.454397306, 15
# console.log maptiler.zoomForPixelSize 4
# maptiler.quadTree(1,1,7)
# console.log 0 to 30

# This is the bottom of the Bay of Plenty
b = [[177.13846,-38.03898],[177.26629,-37.99240]]
maptiler.getTiles b[0][0], b[0][1], b[1][0], b[1][1], 12
