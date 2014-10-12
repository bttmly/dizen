NO_COPY = ["decorator_name", "init", "cleanup"]
  

###
decorator_name: String
bind_all: Boolean
init: Function
cleanup: Function
###
  

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

decorate = ( obj, dec, options ) ->
  dec = registry[dec] if typeof dec is "string"
  throw new Error( "Invalid decorator" ) if is_nil dec


  # copy properties and methods
  for own prop of dec when prop not in NO_COPY
    obj[prop] = dec[prop]
  
  # call decorator's init method
  if typeof dec.init is "function"
    dec.init.call( obj, options )

  # set cleanup to no-op if not defined
  obj.cleanup = noop unless obj.cleanup

  # if decorator has a cleanup method, add it to the cleanup chain
  if obj.cleanup and dec.cleanup and typeof dec.cleanup is "function"
    cleanup = obj.cleanup
    obj.cleanup = ->
      do cleanup
      dec.cleanup.call( obj )

  if is_nil obj.bedizen
    obj.bedizen = ( dec, options ) -> decorate dec, @, options
  
  # return decorated object
  obj

# flip the order of options and obj for simple partial application w options
flip_decorate = ( dec, options, obj ) ->
  decorate( dec, obj, options )

module.exports =
  decorate: decorate
  flip_decorate: flip_decorate
  use: use