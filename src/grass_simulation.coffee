spawner = (klass, board, min_age, max_made, max_made_per_spawn, max_radius) ->

  remaining = max_made
    
  () ->
    if @age < min_age
      return []

    possible = Math.min(max_made_per_spawn, remaining)
    i = Random::int(1, possible)

    while remaining > 0 and i > 0
      remaining -= 1
      i -= 1
      r = Random::int(1, max_radius)
      m = new klass
      m.location = board.random_point_near(@location, r)
      m


fixed_cycle_spawner = (klass, board, min_age, cycle, count, max_radius) ->
  () ->
    if @age < min_age or @age % cycle != 0
      return []

    for i in [0..count]
      r = Random::int(1, max_radius)
      m = new klass
      m.location = board.random_point_near(@location, r)
      m

spawn_at_age = (klass, board, age, count, radius) ->
  () ->
    if @age != age
      return []

    for i in [0..count]
      r = Random::int(1, radius)
      m = new klass
      m.location = board.random_point_near(@location, r)
      m

random_mover = (board, direction_change_chance, max_radius) ->
  () ->
    r = Random::int(1, max_radius)
    @location = board.random_point_near(@location, r)


linear_mover = (board, distance) ->
  dx = distance * Random::sign()
  dy = distance * Random::sign()

  () ->
    @location[0] += dx
    @location[1] += dy


chance_doer = (chance, func) ->
  (args...) ->
    func.apply(this, args) if Random::chance(chance)
  

class GrassSimulation extends Simulation

  constructor: (opts) ->

    default_config =
      rate: 4
      elk:
        initial_count: 20
        move_radius: 1
        move_chance: 0.5
      grass:
        initial_count: 500
        max_age: 30
        spawn:
          min_age: 20
          chance: 0.2
          cycle: 5
          max_made: 25
          max_made_per_spawn: 5
          max_radius: 20
        disease:
          chance: 0.0005

    super(extend({}, default_config, opts))

    b = @board

    class Base
      constructor: ->
        @age = 0
        @location = b.random_point()
        @diseased = false

    s = @config.grass.spawn

    class Grass extends Base
      constructor: ->
        super()
        #@spawn = chance_doer(s.chance, spawner(Grass, b, s.min_age, s.max_made
        #                                     , s.max_made_per_spawn, s.max_radius))
        #@spawn = fixed_cycle_spawner(Grass, b, s.min_age, s.cycle
        #                           , s.max_made_per_spawn, s.max_radius)
        @spawn = chance_doer(s.chance, spawn_at_age(Grass, b, s.min_age, s.max_made_per_spawn, s.max_radius))

    @grasses = for i in [0..@config.grass.initial_count]
      g = new Grass
      g.age = Random::int(1, @config.grass.max_age)
      g

    e = @config.elk

    class Elk extends Base
      constructor: ->
        super()
        @move = chance_doer(e.move_chance, linear_mover(b, e.move_radius))
    
    @elk = (new Elk for i in [0..@config.elk.initial_count])

  tick: ->
    super()

    next_grasses = []

    for grass in @grasses
      grass.age += 1
      if grass.age <= @config.grass.max_age
        grass.diseased = grass.diseased or Random::chance(@config.grass.disease.chance)
        next_grasses.push(grass)
        next_grasses.push(grass.spawn()...)

    @grasses = next_grasses

    for elk in @elk
      elk.move()


class GrassSimulationView
  constructor: (@sim, @canvas, @playback) ->

    @canvas.attr('width', @sim.board.width)
    @canvas.attr('height', @sim.board.height)

    @ctx = @canvas[0].getContext('2d')
    $(@sim).bind('post-tick', () =>

      @ctx.clearRect(0, 0, @sim.board.width, @sim.board.height)
      @ctx.save()

      for grass in @sim.grasses
        @ctx.fillStyle = if grass.diseased then 'red' else 'green'
        @ctx.fillRect(grass.location[0], grass.location[1], 2, 2)

      for elk in @sim.elk
        @ctx.fillStyle = 'blue'
        @ctx.fillRect(elk.location[0], elk.location[1], 4, 4)
        
      @ctx.restore()

      @playback.find('#day').text(@sim.day)
    )

    @playback.find('#start-stop').click(() => @sim.toggle())

# export simulation to browser window object
this.GrassSimulation = GrassSimulation
this.GrassSimulationView = GrassSimulationView
