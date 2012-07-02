class Random
  int: (min = 0, max = 100) ->
    Math.floor(Math.random() * (max - min + 1)) + min

  chance: (chance) ->
    Math.random() < chance

  bool: ->
    @chance(0.5)

  sign: ->
    if @bool() then 1 else -1
