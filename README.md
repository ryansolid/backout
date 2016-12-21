Introduction
============

There already is a much fuller featured KnockoutJS solution for Backbone Models/Collections found at [Knockback](http://kmalakoff.github.io/knockback/), 
that does pretty much everything this project does and more. The goal of this project is slightly different. Instead of being concerned with how to map 
all your Backbone data it focuses solely on making sure events are propogated and reduce the amount of mapping needed.

When one first encounters Knockout the first hurdle is to conceptualize what a ViewModel is in the MVVM pattern used. Since Knockout doesn't really focus 
what the Models or the ViewModels look like it's even more the 'View' in the MV* than even React can claim since it doesn't push you along any particular 
convention. This makes it very flexible and minimal but it also leads to a lot of confusion. How to represent state has been a struggle in Web Applications 
since day one.nWhat generally happens is you sprint off wrapping everything in observables before even really thinking whether you should be. Then the problem 
becomes: How can I best map all my data from the server. There are plugins for that or you can use one of many packages to integrate with a model framework. 
Ultimately the problem still ends up falling on the lose concept of what a ViewModel is. In practive people tend to write 2 types of ViewModels:

* Application Logic View Models: these view models contain specific logic require to handle UI manipulation on your pages, sections, panels, controls, etc..
* Data Model View Models: these view models wrap model/collection data with observables that can be interacted with.

The second category of View Models are the more problematic of the 2 since there is a sort of imperative to keep code DRY to have these shared.  However, in 
practice they can't completely live outside of the context they are being used in and tend to bloat over time. More critically if the instances are shared, 
perhaps as some sort of centralized store you end up that more likely to create undesired dependencies. Especially when you have to consider mapping nested 
model structures. Ultimately in the same way Models are their own tree parallel to the Views, the View Models also follow this pattern and cross connecting 
mess is almost unavoidable.

This was the primary solution React was trying to solve. By componentizing the Application Logic View Models to own their own state representation and essentially 
removing Data Model View Models from the equation by forcing directionality in store interactions it's not nearly as easy to create this tangled web.  That being 
said React doesn't do anything particularly revolutionary as their marketting would let on. And the same patterns can be applied to Knockout. React critizes mutable 
data and 2 way bindnig but most Knockout bindings save (checked, and value) are only one way. If anything the 2 way binding is just a convenience to reduce unnecessary 
boilerplate. In fact in many ways Knockout Dependency Detection Based approach with defered Microtasks is superior to Virtual DOM. Where React is constantly 
recalculating everything (relatively inexpensive) and then only diffing the DOM changes, Knockout is only recalculating what has changed and then only updating the DOM 
where it's changed in batches. This is even more efficient. This is also unlike the much slower Dirty Checking method employed by earlier versions of Angular and Ember 
that React compared itself to since Dirty Check requires checking all dependencies every render cycle. Mind you React can also be expanded to have fine grained control 
it's just a more imperative process that involves lifecycle functions and procedural code that usually ends up resembling large select statements. Whereas Knockout is 
built for fine grained control. The advantage of this becomes immediately obvious if you've ever tried to integrate your own store logic or deal with nested data 
structures. You need to build your own mechanism on top of React Component State. Finding the right store mechanism is a bit of the search for the Holy Grail because 
none them quite feel right and they are always a conceptual complication added on top.

However when it comes when it comes to just getting started React is very simple because it gives the impression when dealing with state you are dealing with plain 
JS objects. Mapping happens as part of the render procedure instead of being yet another part of the state being stored in the View Model. Given Knockout is already 
very efficient only redrawing changes in the DOM it's ok to loosen how many things get recalculated in certain cases to promote simplicity. That is the goal of this 
project. Instead of attempting to map all the model attributes in every situation we just set tell Knockout to recalculate values when certain fields on the model or 
collections change. It's less efficient but not by much since it will only render the DOM if the value changed and the update cycles are still localized. Since most 
binding is one way it lets you deal with the models and collections directly in the view in many cases instead of mapped observables.

Documentation
=============

Backout provides too Knockout Extenders that are wrapped in simple to use specialized Observables.

* ko.observableModel(model, ...keys) - creates an observable that notifies subscribers on setting the model, and/or on key change events
* ko.observableCollection(collection) - creates an observable that notifies subscribers on setting the collection and/or on add, remove, reset, and sort
* ko.observableAttribute(model, key) - creates an ko.observable that is bound to the model attribute
* ko.observableAttributes(model, keys) - returns an object with an observableAttribute for each key

So to set up a View Model with Backout one would use methods like the following:

    var user_model = new Model({
      first_name: 'John',
      last_name: 'Smith'
    });

    this.user = ko.observableModel(user_model);  // create an observable model that notifies it's observers on any change

    this.user().get('first_name') // 'John'

    this.ignorant_user = ko.observableModel(user_model, 'first_name');  // create an observable model that only notifies when the first_name has changed

    Object.assign(this, ko.observableAttributes(user_model, 'first_name', 'last_name')); // create a ko.observable for each attribute specified on the model

    this.first_name('Jack');

    user.get('first_name'); // 'Jack'

    this.list = ko.observableCollection(new Collection());

    this.list().reset([user]);

    this.mapUser = function (model) { return ko.observableModel(model); }  // write a function to map nested View Models if necessary to use.


From here you could bind to the DOM like:

    <span data-bind="text: user.get('first_name')"></span>

    <input type="text" data-bind="value: first_name" />

    // iterate a list and map on the fly
    <ul data-bind="foreach: list().models">
      <li data-bind="with: mapUser($data)">
        <span data-bind="text: get('first_name')"></span>
      </li>
    </ul>


Test
====
TODO: Write tests
