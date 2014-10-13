NO_COPY = 
  "decorator_name": 1
  "init": 1
  "cleanup": 1
  "can_be_overwritten": 1
  "can_overwrite": 1
  "bind_methods": 1
  "safe_methods": 1

noop = ->
  
merge = ( target, sources... ) ->
  for source in sources
    for own key, val of source
      target[key] = val
  target

nonwritable = ( obj, key, val ) ->
  Object.defineProperty obj, key
    enumerable: true
    value: val

decorator_defaults = ->
  safe_methods: true
  bind_methods: false

is_pojo = do ->
  gpo = Object.getPrototypeOf
  obj_proto = Object::
  ( obj ) -> obj_proto is gpo obj

registry = {}

use = ( dec ) ->
  validate_decorator dec
  if registry[dec.decorator_name]
    throw new Error "Decorator already registered as #{ dec.decorator_name }"
  registry[dec.decorator_name] = dec

validate_decorator = ( dec ) ->
  unless typeof dec.decorator_name is "string"
    throw new Error "Bedizen decorators must have a valid `decorator_name` property."

# add the basic dizen properties to an object if it doesn't have them
dizen_base = ( obj = {} ) ->
  obj.cleanup or= noop
  obj._

# copy properties from the decorator to the object, subject to the provided options
actual_decorate = ( obj, dec ) ->
  merge decorator_defaults(), dec
  { bind_all, can_overwrite } = dec
  for own key, val of dec
    continue if NO_COPY[key]
    continue if obj[key]? and not can_overwrite
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

# main function. delegates to above
decorate = ( obj, dec, opt = {} ) ->
  for d in get_decorators dec
    dizen_base obj
    actual_decorate obj, d
    set_cleanup obj, d
    do_init obj, d, opt
  obj

# flip the order of options and obj for simple partial application w options
flip_decorate = ( dec, opt, obj ) ->
  decorate( dec, obj, opt )

sequence = ( decs ) ->
  ( obj, opt ) ->
    # returns a function
    # registry can hold functions directly that just get applied to the object


module.exports =
  decorate: decorate
  flip_decorate: flip_decorate
  use: use