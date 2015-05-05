sqlite = require('spatialite')
# db = new sqlite.Database('test.sqlite')
db = new sqlite.Database(':memory:')

query = "SELECT AsGeoJSON(ST_MakeValid(Centroid(GeomFromText('POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10))')))) AS geojson;"

db.spatialite ->
  db.each query, (err, row) ->
    console.log row.geojson
