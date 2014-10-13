NO_COPY = 
  "decorator_name": 1
  "init": 1
  "cleanup": 1
  "no_overwrite": 1
  "bind_methods": 1
  

###
decorator_name: String
bind_all: Boolean
init: Function
cleanup: Function
###

merge = ( target, sources... ) ->
  for source in sources
    for own key, val of source
      target[key] = val
  target

decorator_defaults = ->
  no_overwrite: true
  bind_methods: false

is_pojo = do ->
  gpo = Object.getPrototypeOf
  obj_proto = Object::
  ( obj ) ->
    obj_proto is gpo obj

is_nil = ( obj ) ->
  obj is null or obj is undefined

noop = ->

dizen = ( obj ) ->

registry = {}

use = ( dec ) ->
  unless typeof dec.decorator_name is "string"
    throw new Error()
  if registry[dec.decorator_name]
    throw new Error()

validate_decorator = ( dec ) ->
  unless typeof dec.decorator_name is "string"
    throw new Error "Bedizen decorators must have a valid `decorator_name` property."

# add the basic dizen properties to an object if it doesn't have them
dizen_base = ( obj ) ->
  obj.cleanup or= noop

# copy properties from the decorator to the object, subject to the provided options
actual_merge = ( obj, dec ) ->
  merge decorator_defaults(), dec
  { bind_all, no_overwrite } = dec
  for own key, val of dec
    continue if NO_COPY[key]
    continue if obj[key]? and no_overwrite
    obj[key] = if bind_all and typeof val is "function" then val.bind obj else val
  obj

# set the object's cleanup chain
set_cleanup = ( obj, dec ) ->
  if typeof dec.cleanup is "function"
    cleanup = obj.cleanup
    obj.cleanup = ->
      cleanup()
      dec.cleanup.call obj

# call the decorator's init method, if extant
do_init = ( obj, dec, opt ) ->
  dec.init.call obj, opt if typeof dec.init is "function"

# normalize the decorator argument into an array of decorator objects
get_decorators = ( dec ) ->
  if Array.isArray dec
    decs = dec.map ( str ) -> 
      if typeof str is "string" then str else registry[str]
  else if typeof dec is "string"
    decs = [registry[dec]]
  else 
    decs = [dec]
  validate_decorator dec for dec in decs
  decs

# actually decorate it
decorate = ( obj, dec, opt = {} ) ->
  get_decorators dec
  dizen_base obj
  actual_merge obj, dec
  set_cleanup obj, dec
  do_init obj, dec, opt
  obj

# flip the order of options and obj for simple partial application w options
flip_decorate = ( dec, opt, obj ) ->
  decorate( dec, obj, opt )

module.exports =
  decorate: decorate
  flip_decorate: flip_decorate
  use: use