-- This is just to get accurate values for gauging our test scripts

-- Get correct Global Mercator coordinates
select
  st_AsText(
    ST_Transform(
      ST_GeomFromText('POINT(-123 52)',4326),3857
    )
  )
