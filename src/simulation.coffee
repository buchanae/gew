class Simulation
  constructor: (opts) ->

    default_config =
      rate: 1000
      max_days: 250

    @config = extend({}, default_config, opts)

    @day = 0
    @interval_id = null
    @board = new Board(@config.board.width, @config.board.height)

  start: ->
    if @day < @config.max_days
      cb = () =>
        @day += 1
        $(this).trigger('pre-tick')
        @tick()
        $(this).trigger('post-tick')

        if @day > @config.max_days
          @stop
          $(this).trigger('end')

      cb()
      @interval_id = setInterval(cb, @config.rate)

  stop: ->
    clearInterval(@interval_id)
    @interval_id = null

  running: -> @interval_id?

  toggle: -> if @running() then @stop() else @start()

  tick: ->
