redis = require('redis').createClient!
redis.lpop 'maptiler', (e,r) ->
  console.log JSON.parse r
  redis.quit!
