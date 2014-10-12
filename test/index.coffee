require( "chai" ).should()

dizen = require ".."

class House
  constructor: ( @_sq_ft ) ->

  get_sq_ft: -> @_sq_ft


is_nil = ( val ) ->
  val is null or val is undefined


bedroom_decorator =
  init: ->
    @_bedrooms = 0 if is_nil @_bedrooms
    @_bedrooms++
    @_sq_ft += 225

  has_bedrooms: true

  get_bedrooms: -> @_bedrooms


bathroom_decorator =
  init: ->
    @_bathrooms = 0 if is_nil @_bathrooms
    @_bathrooms++
    @_sq_ft += 100

  has_bathrooms: true

  get_bathrooms: -> @_bathrooms


deck_decorator =
  init: ->
    @_decks = 0 if is_nil @_decks
    @_decks++

  has_deck: true

  enjoy_sunshine: -> "Enjoying the sunshine on the deck."

error_decorator = 
  init: ->
    throw new Error() unless @props_added

  props_added: true

configurable_decorator =
  init: ( options ) ->
    @options_works = options.works
    @called_on_init options.init_option

  called_on_init: ( opt ) ->
    @init_option = opt

describe "decorate", ->

  house = undefined
  beforeEach ->
    house = new House 1000

  it "adds decorates an object with properties and methods from another object", ->
    dizen.decorate house, bedroom_decorator
    house.get_bedrooms.should.be.a "function"
    house.get_bedrooms.should.equal bedroom_decorator.get_bedrooms
    house.has_bedrooms.should.equal true

  it "calls the decorator's `init` method on the object, but doesn't add it to the object", ->
    dizen.decorate house, bedroom_decorator
    house.get_bedrooms().should.equal 1
    house.get_sq_ft().should.equal 1225
    is_nil( house.init ).should.equal true

  it "calls the decorator's `init` method *after* adding other methods and properties", ->
    ( -> dizen.decorate house, error_decorator ).should.not.throw()

  it "calls the decorator's `init` method with `options` as argument if present", ->
    dizen.decorate house, configurable_decorator, { works: true, init_option: "heyo" }
    house.options_works.should.equal true
    house.init_option.should.equal "heyo"


















