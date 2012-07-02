extend = (obj, mixins...) ->
  for mixin in mixins
    obj[k] = v for k, v of mixin
  obj


include = (klass, mixins...) ->
  for mixin in mixins
    extend klass.prototype, mixin
