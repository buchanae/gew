var Grass = Backbone.Model.extend({

  defaults: {
    alive: true,
    location: [0, 0],
    max_location: [100, 100],
    age: 0,
    max_age: 30,
    max_seeds: 25,
    seed_age: 25,
    seed_chance: 0.015,
    seed_radius: 20,
    diseased: false,
    disease_chance: 0.005,
  },

  should_seed: function() {
    return this.get('age') > this.get('seed_age') 
           && random_chance(this.get('seed_chance'));
  },

  seed: function() {

    var g_loc = this.get('location');
    var r = this.get('seed_radius');

    var c = random_int(1, this.get('max_seeds'));
    var new_grass = [];

    for (var i = 0; i < c; i++) {

      var new_loc = [
        g_loc[0] + (random_int(0, r) * (random_boolean ? 1 : -1)),
        g_loc[1] + (random_int(0, r) * (random_boolean ? 1 : -1)),
      ];

      var max_loc = this.get('max_location');
      if (new_loc > max_loc[0]) new_loc = max_loc[0];
      if (new_loc > max_loc[1]) new_loc = max_loc[1];

      var ng = new Grass({
        location: new_loc,
      });
      new_grass.push(ng);
    }
    this.trigger('seed', new_grass);

    return new_grass;
  },

  die: function() {
    this.set('alive', false);
    this.trigger('die');
  },

  tick: function() {
    this.set('age', this.get('age') + 1);

    if (this.get('age') > this.get('max_age')) this.die();
    else {

      if (!this.get('diseased') && random_chance(this.get('disease_chance'))) {
        this.set('diseased', true);
      }

      if (this.should_seed()) {
        this.seed();
      }
    }
  },
});

var GrassCollection = Backbone.Collection.extend({
  model: Grass,
});
