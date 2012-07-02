class Board

  constructor: (@width, @height) ->

  max_point: ->
    [@width - 1, @height - 1]

  random_point: ->
    max = @max_point()
    [Random::int(0, max[0]), Random::int(0, max[1])]

  bounds_near: (location, radius) ->
    rx_min = location[0] - radius
    ry_min = location[1] - radius
    rx_min = 0 if rx_min < 0
    ry_min = 0 if ry_min < 0

    max = @max_point()
    rx_max = location[0] + radius
    ry_max = location[1] + radius
    rx_max = max[0] if rx_max > max[0]
    ry_max = max[1] if ry_max > max[1]

    [rx_min, rx_max, ry_min, ry_max]

  random_point_near: (location, radius) ->
    bounds = @bounds_near(location, radius)
    [Random::int(bounds[0], bounds[1]), Random::int(bounds[2], bounds[3])]
