Function::bind or= require "function-bind"

should = require( "chai" ).should()

dizen = require "../src/"


###

Decorators for tests.

###

attempt = ( fn ) ->
  ret = undefined
  try
    ret = fn
  catch e
    # ...

attempt = ( fn ) ->
  try
    ret = fn()
  catch e
    ret = e
  ret
  
bedroom_decorator =
  decorator_name: "bedroom_decorator"
  init: ->
    @_bedrooms = 0 unless @_bedrooms?
    @_bedrooms++
    @_sq_ft += 225
  has_bedrooms: true
  get_bedrooms: -> @_bedrooms


bathroom_decorator =
  decorator_name: "bathroom_decorator"
  init: ->
    @_bathrooms = 0 unless @_bedrooms?
    @_bathrooms++
    @_sq_ft += 100
  has_bathrooms: true
  get_bathrooms: -> @_bathrooms


deck_decorator =
  decorator_name: "deck_decorator"
  init: ->
    @_decks = 0 unless @_decks?
    @_decks++
  has_deck: true
  enjoy_sunshine: -> "Enjoying the sunshine on the deck."


error_decorator = 
  decorator_name: "error_decorator"
  init: ->
    throw new Error() unless @props_added
  props_added: true


configurable_decorator =
  decorator_name: "configurable_decorator"
  init: ( options ) ->
    @options_works = options.works
    @called_on_init options.init_option
  called_on_init: ( opt ) ->
    @init_option = opt


cleanup_decorator_a =
  decorator_name: "cleanup_decorator_a"
  cleanup: ->
    @a_cleaned_up = true


cleanup_decorator_b =
  decorator_name: "cleanup_decorator_b"
  cleanup: ->
    throw new Error unless @a_cleaned_up
    @b_cleaned_up = true


cleanup_decorator_c =
  decorator_name: "cleanup_decorator_c"
  cleanup: ->
    throw new Error() unless @a_cleaned_up and @b_cleaned_up
    @c_cleaned_up = true

bind_test_decorator =
  decorator_name: "bind_test_decorator"
  bind_all: true
  prop: true
  return_this_a: -> @
  return_this_b: -> @

unnamed_decorator =
  prop: true

no_overwrite_decorator =
  decorator_name: "no_overwrite_decorator"
  can_overwrite: false
  _sq_ft: 2000

###

Tests

###

describe "decorate", ->

  house = undefined
  beforeEach ->
    house = 
      _sq_ft: 1000
      get_sq_ft: -> @_sq_ft

  it "decorates an object with properties and methods from another object", ->
    dizen.decorate house, bedroom_decorator
    house.get_bedrooms.should.be.a "function"
    house.get_bedrooms.should.equal bedroom_decorator.get_bedrooms
    house.has_bedrooms.should.equal true

  it "doesn't add the `decorator_name` property to the object", ->
    dizen.decorate house, bedroom_decorator
    ( house.decorator_name? ).should.equal false

  it "calls the decorator's `init` method on the object, but doesn't add it to the object", ->
    dizen.decorate house, bedroom_decorator
    house.get_bedrooms().should.equal 1
    house.get_sq_ft().should.equal 1225
    ( house.init? ).should.equal false

  it "calls the decorator's `init` method *after* adding other methods and properties", ->
    ( -> dizen.decorate house, error_decorator ).should.not.throw()

  it "calls the decorator's `init` method with `options` as argument if present", ->
    dizen.decorate house, configurable_decorator, { works: true, init_option: "heyo" }
    house.options_works.should.equal true
    house.init_option.should.equal "heyo"

  it "the composite `cleanup` method calls each decorator's cleanup method in the order they were added", ->
    dizen.decorate house, cleanup_decorator_a
    dizen.decorate house, cleanup_decorator_b
    dizen.decorate house, cleanup_decorator_c
    ( -> house.cleanup() ).should.not.throw()
    house.a_cleaned_up.should.equal true
    house.b_cleaned_up.should.equal true
    house.c_cleaned_up.should.equal true

  it "binds a decorator's methods to the object when `bind_all` option is truthy", ->
    dizen.decorate house, bind_test_decorator
    house.return_this_a.call( {} ).should.equal house
    house.return_this_b.call( [] ).should.equal house
    house.prop.should.equal true

  it "throws an error when a decorator doesn't have a string `decorator_name` property", ->
    err = attempt -> dizen.decorate house, unnamed_decorator
    err.should.be.instanceof Error
    err.message.should.equal "Decorators must have a valid `decorator_name` property."

  it "throws errors on attempted overwrites when `can_overwrite` option is falsy", ->
    err = attempt -> dizen.decorate house, no_overwrite_decorator
    err.should.be.instanceof Error
    err.message.should.equal "Refusing to overwrite _sq_ft"










