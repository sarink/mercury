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

This will look for a region on the current page which has a region_name of "pageTitle" and has a region_type of "simple". It will render its value inside of the ````<h1>```` tag, but also wrap itself in a block-level element (a div) which has the classes "foo" and "bar".
Let's say the user typed "Mercury is awesome!" and hit the save button, you'd get....
````
<h1 id="title"><div class="foo bar">Mercury is awesome!</div></h1>
````

snippets
------------
I encourage you to first understand how snippets work in the original mercury by reading jejacks0n's wiki.

I took the idea of snippets from the original mercury and basically use them to create everything you'd ever need. Snippets are powerful, and are now very easy to create. In fact, I've done away with image_regions completely, and simply implemented them as an image_snippet. You shouldn't ever have to create your own region types anymore, in theory, you should be able to create a snippet for anything you need. 
Snippets are customizable through the options popup view and draggable within a snippet region.
Snippet regions can be customized as well. By default there is the ability to specify which types of snippets are allowed to be dragged into a region, and also how many. Inside of mercury_helper.rb you can see how this is achieved through the use of the data-accepted_snippets and data-number_of_snippets variables.

The accepted_snippets list is a comma delimited string of which snippet names are allowed to be dropped into the region. 

The number_of_snippets variable is the maximum number of snippets that can be dropped into the region.

Now that you understand how to create a snippet region, let's talk about how to create the actual snippets that your user can drop into your snippet regions...

Mercury identifies a snippet as anything with a data-snippet_name attribute. In addition to this, there a few other options you can specify: data-snippet_show_options and data-snippet_default_options.

data-snippet_show_options: This should either be "true" or "false" - by default, when you drag a snippet into a snippet region, mercury pops up the snippet options view (app/views/mercury/snippets/your-snippet-name/options.html.erb). If you set data-snippet_show_options to false, it will not do this. Instead, it will use the data-snippet_default_options attribute to create the snippet. The user can still modify the options by hovering over the snippet and clicking the options button on the snippet toolbar that appears. This only prevents the initial options popup.
** THIS DOES NOT WORK YET ** see app/javascripts/mercury/snippet.js.coffee:7 - this is where it has yet to be implemented

data-snippet_default_options: This is an optional JSON object which can represent the default options for a snippet. If you specify this, this object will be POST'ed to the server when loading the options view (app/views/mercury/snippets/your-snippet-name/options.html.erb) to pre-populate the form. Furthermore, if you wish to use data-snippet_show_options="false" for a snippet - then you require this.

To understand how all of this comes together, you should look at how images work.

images
------------
As previously stated, images have been implemented as snippets. If you'd like to create your own snippets, understanding how images are implemented is probably a good start.

Here's a quick example of how you might implement a sortable/draggable image gallery of 8 images
app/views/pages/_home.html.erb
````
<div class="photo-gallery">
    <%= eight_images_snippet_region("photoGallery", {"class" => "thumbs span-8"}) %>
</div>
````
app/helpers/mercury_helper.rb
````
def eight_images_snippet_region(region_name, attrs={})
    render_snippet_region(region_name, "image", 8, attrs)
end
````
app/views/mercury/panels/images.html.erb
````
