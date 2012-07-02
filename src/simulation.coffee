class Simulation
  constructor: (opts) ->

    default_config =
      rate: 1
      max_days: 250
      board:
        width: 300
        height: 300

    @config = extend({}, default_config, opts)

    @day = 0
    @interval_id = null
    @board = new Board(@config.board.width, @config.board.height)

  start: ->
    cb = () =>
      if @day >= @config.max_days
        @stop()
        $(this).trigger('end')
      else
        $(this).trigger('pre-tick')
        @tick()
        $(this).trigger('post-tick')

    cb()
    @interval_id = setInterval(cb, 1000 / @config.rate)

  stop: ->
    clearInterval(@interval_id)
    @interval_id = null

  running: -> @interval_id?

  toggle: -> if @running() then @stop() else @start()

  tick: ->
    @day += 1
