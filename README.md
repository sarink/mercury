mercury
=======

Mercury Editor: The Rails HTML5 WYSIWYG editor

1. Add to Gemfile:
````
gem 'rails_admin'
gem 'mercury-rails', :git => 'git://github.com/sarink/mercury.git'
````

2. Install rails-admin
Run ````rails g rails_admin:install````
MUST install with the defaults (mount at /admin, user model named user)
    
3. Create a home/index page, I recommend adding something like this to your seeds.db (for now, these have to be created manually)
````Mercury::Page.create(name: "home", title: "Home", description: "Home Page")````
    
4. Install mercury
Run ````rails g mercury:install```` (this will run rake db:migrate and rake db:seed for you at the end)
    
5. Restart your server, and at the bottom left of the home page there should be an "Edit page" link
