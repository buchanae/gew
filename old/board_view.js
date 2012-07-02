var BoardView = Backbone.View.extend({

  ctx: null,

  initialize: function(attributes) {
    this.ctx = this.el.getContext('2d');
    this.model.on('tick-complete', this.render, this);
  },

  render_grass: function(g) {

    var loc = g.get('location');
    var ctx = this.ctx;

    ctx.save();
    ctx.fillStyle = g.get('diseased') ? 'red' : 'green';
    ctx.fillRect(loc[0], loc[1], 3, 3);
    ctx.restore();
  },

  clear: function() {
    this.ctx.clearRect(0, 0, this.model.board.width, this.model.board.height);
  },

  render: function() {

    this.clear();
    this.model.grasses.each(this.render_grass, this);

    return this;
  }
});
