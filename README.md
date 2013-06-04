mercury
=======
Mercury Editor: The Rails HTML5 WYSIWYG editor

I've taken what jejacks0n made and expanded upon it. This is an all-inclusive CMS built with the mercury editor. I realize that this may not be for everyone, but for me this satisfies most of the tasks that I need to do on any project.
The biggest/most notable changes are:

- Implemented back end for ALL types of mercury regions, including storage and retrieval/display
- Enhanced snippet functionality so they are straight forward and easy to create
- Basic page system
- Rails admin integration for those more advanced tasks
- Built in authentication through devise (w/custom User model)
- Built in Drag-n-drop images/assets "gallery" + uploader
- Automatically adds an "edit page" link at the bottom of your application.html


install
--------
1. Add to Gemfile
````
gem 'rails_admin'
gem 'mercury-rails', :git => 'git://github.com/sarink/mercury.git'
````

2. Install rails-admin
````rails g rails_admin:install```` MUST install with the defaults (mount at /admin, user model named user)
    
3. Install mercury ````rails g mercury:install```` (this will run rake db:migrate and rake db:seed for you at the end). Make sure to hit yes when asked to overwrite files
    
4. Restart your server

5. Create a Page, add some Regions to it, and away you go! (your default login is admin/admin123)


pages
--------
For the time being, Pages must be created manually. You can create them by manually editing the db, through the rails console, or adding a line like this to your db/seeds.db ````Mercury::Page.create(name: "home", title: "Home", description: "Home Page")````

The above line will look inside of ``app/views/pages/`` for a ``_home.html.erb`` file. The name of a page must match its filename (minus the _), and all page views are created as partials beginning with an underscore.


regions
---------
Instead of manually adding ``data-attributes`` and tags to our markup to let mercury know about the regions on a page, there are helper functions inside of ``app/helpers/mercury_helper.rb``. I suggest taking a look at this file to see how it works (it has lengthy comments and the code is pretty straight forward). 


A region has 4 properties: ``region_name, region_type, attrs, value``

``region_name``: Every region must have a unique name to the page which it is on. The ``render_region`` code looks up the current page, and tries to match regions by name.

``region_type``: The region type should be automatically set in your function inside of mercury_helper.rb

``attrs``: The attributes hash can be anything that you require. This was designed to render your html attributes (such as id, class, width... etc) just as it would if you were writing raw html. However, if you need to add data-attributes here, you can also do that, but you'll have to tell mercury specifically which ones you want to save by editing mercury.js:236 saveAttributes[] (this is because there are some data-attributes used internally which we don't need or want to persist in the db). Note that this is a global list, and every region that possesses any of the attributes in saveAttributes[] will be saved. There's no way to say "save data-attributeX for region Y, but ignore it for region Z"

``value``: The value is whatever markup the user typed in or did to the region. This is stored and retrieved as-is.

Here's a simple example:
````
<h1 id="title"><%= simple_region("pageTitle", {"class" => "foo bar"}) %></h1>
````

This will look for a region on the current page which has a ``region_name`` of "pageTitle" and has a ``region_type`` of "simple". It will render its value inside of the ``<h1>`` tag, but also wrap itself in a block-level element (a div) which has the classes "foo" and "bar".
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

The ``data-accepted_snippets`` attribute is a comma delimited string of which snippet names are allowed to be dropped into the region. 

The ``data-number_of_snippets`` attribute is the maximum number of snippets that can be dropped into the region.

Now that you understand how to create a snippet region, let's talk about how to create the actual snippets that your user can drop into your snippet regions...

Mercury identifies a snippet as anything with a ``data-snippet_name`` attribute. In addition to this, there a few other options you can specify: ``data-snippet_show_options`` and ``data-snippet_default_options``.

``data-snippet_show_options``: This should either be "true" or "false" - by default, when you drag a snippet into a snippet region, mercury pops up the snippet options view (``app/views/mercury/snippets/your-snippet-name/options.html.erb``). If you set ``data-snippet_show_options="false"``, it will not do this. Instead, it will use the ``data-snippet_default_options attribute`` to create the snippet. The user can still modify the options by hovering over the snippet and clicking the options button on the snippet toolbar that appears - this only prevents the initial options popup.
** THIS DOES NOT WORK YET ** see app/javascripts/mercury/snippet.js.coffee:7 - this is where it has yet to be implemented

``data-snippet_default_options``: This is an optional JSON object (string) which can represent the default options for a snippet. If you specify this, this object will be POST'ed to the server when loading the options view (``app/views/mercury/snippets/your-snippet-name/options.html.erb``) to pre-populate the form. Furthermore, if you wish to use ``data-snippet_show_options="false"`` for a snippet, then you require this.

To understand how all of this comes together, you should look at how images work.

images
------------
As previously stated, images have been implemented as snippets. If you'd like to create your own snippets, understanding how images are implemented is probably the best place to start.

Let's take a look at how an image_snippet_region works and how an image snippet that can be dropped into this region is made


This code creates an image_snippet_region on your page called singlePhoto

app/views/pages/_your-page.html.erb:
````
<div class="single-photo">
    <%= image_snippet_region("singlePhoto", {"class" => "span-4"}) %>
</div>
````

Here's the default image_snippet_region implementation already included

app/helpers/mercury_helper.rb:
````
def image_snippet_region(region_name, attrs={})
    render_snippet_region(region_name, "image", 1, attrs)
end
````

Here's how we create the snippet on the client side to be dropped into the image_snippet_region that will be rendered from the code above. This is recognized as a snippet because we specified the data-snippet_name attribute. We've chosen to provide default options by putting a JSON object in the data-snippet_default_options attribute containing the same parameters as our app/views/mercury/snippets/image/options.html.erb form does. Note that the "file" variable is valid here because we're dynamically rendering this html inside of a JS template . Most of the time this will probably just be hard coded HTML as you create individual snippets.

app/views/mercury/panels/images.html.erb
````
    <img draggable="true"
         src="{%=file.thumbnail_url%}"
         data-snippet_name="image"
         data-snippet_show_options="true" 
         data-snippet_default_options="{%= JSON.stringify({
            src: file.url,
            title: file.name,
            width: '',
            height: '',
         }) %}"
     />
````

To recap...
Now, since we've provided a ``data-snippet_name`` attribute for this ``img`` tag, mercury will see this as a snippet, and allow it to be dragged. If it is dragged over a snippet region which lists "image" inside of its ``data-accepted_snippets`` list, a + icon will appear and you can drop the snippet there to insert it. When the user lets go, since we have specified ``data-snippet_show_options="true"``, mercury will try and load ``app/views/mercury/snippets/image/options.html.erb`` in a modal box, lastly since we've specified a JSON object string inside ``data-snippet_default_options``, any matching properties on that options form will automatically be pre-populated with this data.

To understand how this options form works, and ultimately how this will be rendered on the page (mercury will load ``app/views/mercury/snippets/image/preview.html.erb``), read jejacks0n's wiki. The implementation of this part of snippets has not changed. This is also exactly how it is rendered for an end user visiting the page. By default, mercury will have put a [snippet_#id] string into the snippet region. ``mercury_helper.rb`` will replace this string with the rendered HTML from the ``preview.html.erb`` file.


rails admin
----------------
Since most apps will require some at least semi-advanced database relations/stuff that is better served with a traditional CMS (CRUD for your models), there is an "Advanced" button on the toolbar which launches rails-admin in a full size lightbox iframe.

To learn more about customizing this, read the rails-admin documentation.


devise
----------
Since rails-admin ships with devise, and every CMS will need some sort of authentication system, I figured may as well just bundle mercury with devise....but modified. I didn't like how devise makes you login with email, so you can now login with a username or email address. Additionally, an "admin" flag was added, both mercury and rails admin will only allow a user to login if this is true.
