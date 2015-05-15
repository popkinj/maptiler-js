maptiler = require "../dist/maptiler.js"
b = [[177.13846,-38.03898],[177.26629,-37.99240]]
maptiler.redis = yes
tiles = maptiler.getTiles b[0][0], b[0][1], b[1][0], b[1][1], 12
console.log tiles
#
# If not useing redis... The following should be producced
# on standard output.
# Otherwise it gets stuffed into redis.
# [0:
#   extent3857: [19714638.33531266, -4588667.6820157, 19724422.274933163, -4578883.742395198],
#   extent4326: [177.09960937500003, -38.06539235133247, 177.1875, -37.996162679728116],
#   google: [12, 4063, 2516],
#   tms: [12, 4063, 1579]]
# 1: ...
# 2: ...
# 3: ...
#
