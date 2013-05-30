mercury
=======
Mercury Editor: The Rails HTML5 WYSIWYG editor

install
--------
1. Add to Gemfile
````
gem 'rails_admin'
gem 'mercury-rails', :git => 'git://github.com/sarink/mercury.git'
````

2. Install rails-admin
````rails g rails_admin:install```` MUST install with the defaults (mount at /admin, user model named user)
    
3. Install mercury ````rails g mercury:install```` (this will run rake db:migrate and rake db:seed for you at the end)
    
4. Restart your server


pages
--------
For the time being, Pages must be created manually. You can create them by manually editing the db, through the rails console, or adding a line like this to your db/seeds.db ````Mercury::Page.create(name: "home", title: "Home", description: "Home Page")````

The above line will look inside of "app/views/pages/" for a "_home.html.erb" file. The name of a page must match its filename (minus the _), and all page views are created as partials beginning with an underscore.


regions
---------
Instead of manually adding data-attributes and tags to our markup to let mercury know about the regions on a page, there are helper functions inside of app/helpers/mercury_helper.rb. By default, there are 4 types of regions already setup: full_region, simple_region, any_snippet_region, and image_snippet_region
A region has only two properties: a name, and a hash of attributes
Every region must have a unique name to the page which it is on. The render_region code looks up the current page, and tries to match regions by name.
The attributes hash 
I suggest taking a look at this file to see how it works (it has lengthy comments and the code is pretty straight forward).  This is where you will add your own snippet regions.
Here's an easy example of how you would use the default implementation of the built in regions
````
<div id="title"> <%= simple_region("pageTitle
````
Here's a quick example of how you might implement a sortable/draggable image gallery
````
<div class="photo-gallery">
    <%= 
    <%= image_snippet_region("photoGallery", {"class" => "thumbs span-8"}) %>
</div>
