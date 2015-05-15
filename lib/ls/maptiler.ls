maptiler =
  redis: no # Default to no Redis
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

    # Define the container for the tiles
    if @redis
      redis = require('redis').createClient!
      redis.on 'error', -> Console.log "Error with Redis: #it"
      redis.del 'maptiler' # Clear previous list
    else
      tiles = []

    for ty from tilePos1[1] to tilePos2[1]
      for tx from tilePos1[0] to tilePos2[0]
        google = @googleTile(tx,ty,zoom)
        bounds3857 = @tileBounds(tx,ty,zoom)
        bounds4326 = @tileLatLonBounds(tx,ty,zoom)

        meta = # Form the data package
          tms: [zoom,tx,ty]
          google: [zoom,tx,google[1]]
          extent3857:bounds3857
          extent4326:bounds4326

        # If redis support is enabled push it there.
        # Otherwise just put into the tiles array
        if @redis then redis.rpush 'maptiler' meta else tiles.push meta

    # Return redis key name or tile array
    if @redis
      redis.quit!
      'maptiler'
    else
      tiles

# Export as a module if in node/io
module.exports = maptiler if module?.exports?
