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
Instead of manually adding data-attributes and tags to our markup to let mercury know about the regions on a page, there are helper functions inside of app/helpers/mercury_helper.rb. I suggest taking a look at this file to see how it works (it has lengthy comments and the code is pretty straight forward). 


A region has 4 properties: region_name, region_type, attrs, value

region_name: Every region must have a unique name to the page which it is on. The render_region code looks up the current page, and tries to match regions by name.

region_type: The region type should be automatically set in your function inside of mercury_helper.rb

attrs: The attributes hash can be anything that you require. This was designed to render your html attributes (such as id, class, width... etc) just as it would if you were writing raw html. However, if you need to add data-attributes here, you can also do that, but you'll have to tell mercury specifically which ones you want to save by editing mercury.js:236 saveAttributes[] (this is because there are some data-attributes used internally which we don't need or want to persist in the db). Note that this is a global list, and every region that possesses any of the attributes in saveAttributes[] will be saved. There's no way to say "save data-attributeX for region Y, but ignore it for region Z"

value: The value is whatever markup the user typed in or did to the region. This is stored and retrieved as-is.

Here's a simple example:
````
<h1 id="title"><%= simple_region("pageTitle", {"class" => "foo bar"}) %></h1>
````
This will look for a region on the current page which has a region_name of "pageTitle" and has a region_type of "simple". It will render its value inside of the <h1> tag, but also wrap itself in a block-level element (a div) which has the classes "foo" and "bar".
Let's say the user typed "Mercury is awesome!" and hit the save button, you'd get....
````
<h1 id="title"><div class="foo bar">Mercury is awesome!</div></h1>
````

snippets
------------
Here's a quick example of how you might implement a sortable/draggable image gallery
````
<div class="photo-gallery">
    <%= 
    <%= image_snippet_region("photoGallery", {"class" => "thumbs span-8"}) %>
</div>
