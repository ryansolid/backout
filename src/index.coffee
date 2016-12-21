ko = require 'knockout'
{Model, Collection} = require 'backbone'

###
# Extension to trigger obsv on model attribute changes
###
ko.extenders.modelChange = (obsv, keys) ->
  handler = null
  event_names = ''
  if keys?.length
    event_names = ("change:#{key}" for key in keys).join(' ')
  else event_names = 'change'
  model = obsv.peek()
  sub = obsv.subscribe (new_model) ->
    return if new_model is model
    model.off event_names, handler if handler and model
    return unless model = new_model
    model.on event_names, handler = (model) -> obsv.notifySubscribers(model)

  if model?
    model.on event_names, handler = (model) -> obsv.notifySubscribers(model)

  og_dispose = obsv.dispose
  obsv.dispose = ->
    sub.dispose()
    model?.off event_names, handler
    og_dispose?.apply(obsv, arguments)

  return obsv

###
# Extension to trigger obsv on collection changes
###
ko.extenders.collectionChange = (obsv, options) ->
  collection = obsv.peek()
  sub = obsv.subscribe (new_collection) ->
    return if new_collection is collection
    collection.off 'add reset remove sort', handler if handler and collection
    return unless collection = new_collection
    collection.on 'add reset remove sort', handler = -> obsv.notifySubscribers(collection)
  collection.on 'add reset remove sort', handler = -> obsv.notifySubscribers(collection)

  og_dispose = obsv.dispose
  obsv.dispose = ->
    sub.dispose()
    collection?.off 'add reset remove sort', handler
    og_dispose?.apply(obsv, arguments)

  return obsv

###
# Easy to use wrapped extensions
###
ko.observableModel = (model, keys...) ->
  keys = keys[0] if arguments.length is 2 and Array.isArray(keys[0])
  ko.observable(model).extend(modelChange: keys)

ko.observableCollection = (collection) -> ko.observable(collection or= new Collection()).extend(collectionChange: true)

ko.observableAttribute = (model, key) ->
  obsv = ko.observable(model.get(key))
  sub = obsv.subscribe (new_value) ->
    return if new_value is model.get(key)
    model.set({"#{key}": new_value})

  model.on "change:#{key}", handler = (model, new_value) -> obsv(new_value)
  og_dispose = obsv.dispose
  obsv.dispose = ->
    sub.dispose()
    model.off "change:#{key}", handler
    og_dispose?.apply(obsv, arguments)

  return obsv

ko.observableAttributes = (model, keys...) ->
  attrs = {}
  keys = keys[0] if arguments.length is 2 and Array.isArray(keys[0])
  for key in keys
    attrs[key] = ko.observableAttribute(model, key)
  attrs