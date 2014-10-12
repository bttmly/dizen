NO_COPY = ["decorator_name", "init", "cleanup"]

noop = ->

dizen = ( obj ) ->

registry = {}

decorated = new Set()

use = ( dec ) ->
  unless typeof dec.decorator_name is "string"
    throw new Error()
  if registry[dec.decorator_name]
    throw new Error()

decorate = ( name, obj, options ) ->
  # ensure 
  throw new Error() unless registry[name]
  dec = registry[name]

  # copy properties and methods
  for prop of decorator when prop not in NO_COPY
    obj[prop] = decorator[prop]
  
  # call decorator's init method
  if init of decorator
    init.call( obj, options )

  # set cleanup to no-op if not defined
  obj.cleanup = noop unless obj.cleanup

  # if decorator has a cleanup method, add it to the cleanup chain
  if obj.cleanup and dec.cleanup and typeof dec.cleanup is "function"
    cleanup = obj.cleanup
    obj.cleanup = ->
      do cleanup
      dec.cleanup.call( obj )
  
  # return decorated object
  obj

# flip the order of options and obj for simple partial application w options
flipDecorate = ( dec, options, obj ) ->
  decorate( dec, obj, options )

