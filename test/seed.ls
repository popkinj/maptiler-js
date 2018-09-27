maptiler = require "../maptiler.js"
# Bottom of bay of plenty
# b = [[177.13846,-38.03898],[177.26629,-37.99240]]
# All of New Zealand
l = 166.425173
b = -47.290030
r = 178.578173
t = -34.129501

# Sample BC area
# l = -126.68540
# b = 50.25397
# r = -126.18878
# t = 50.48561

maptiler.redis.turnOn!
callback = -> console.log it
maptiler.getTiles l,b,r,t,12,callback
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
