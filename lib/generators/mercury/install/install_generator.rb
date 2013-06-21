require 'rails/generators/active_record'

module Mercury
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root Mercury::Engine.root

      desc "Installs Mercury into your application. PLEASE ENSURE YOU HAVE ALREADY INSTALLED RAILS-ADMIN AND DEVISE!! (run rails g rails_admin:install)"

      # class_option :orm, :default => 'active_record', :banner => 'mongoid',
                   # :desc => 'ORM for required models -- active_record, or mongoid (mongoid support is incomplete!)'

      def add_gemfile_dependencies
        # append_to_file "Gemfile", %Q{\ngem 'rails_admin'}
        append_to_file "Gemfile", %Q{\ngem 'paperclip'}
        append_to_file "Gemfile", %Q{\ngem 'coffee-script-source', '1.4.0'}

        # if options[:orm] == 'mongoid'
          # append_to_file "Gemfile", %Q{\ngem 'mongoid-paperclip', :require => 'mongoid_paperclip'}
        # end
      end

      def copy_models
        # if options[:orm] == 'mongoid'
          # copy_file 'app/models/mercury/mongoid_paperclip_image.rb', 'app/models/mercury/image.rb'
        # else
            # copy_file 'app/models/mercury/history.rb'
            # copy_file 'app/models/mercury/page.rb'
            # copy_file 'app/models/mercury/region.rb'
            copy_file 'app/models/user.rb'
            copy_file 'app/models/upload.rb'
        # end
      end

      def copy_views
        copy_file 'app/views/layouts/mercury.html.erb'
        directory 'app/views/devise'
        directory 'app/views/mercury'
        inject_into_file('app/views/layouts/application.html.erb', :before => "</body>") do
          "<%= link_to 'Edit Page', mercury_edit_path(@page.name) if !@page.nil? %>\n"
        end
      end

      def copy_assets
        copy_file 'app/assets/javascripts/mercury.js'
        copy_file 'app/assets/stylesheets/mercury.css'
      end

      def copy_controllers
        # copy_file 'app/controllers/mercury/histories_controller.rb'
        # copy_file 'app/controllers/mercury/mercury_controller.rb'
        # copy_file 'app/controllers/mercury/pages_controller.rb'
        copy_file 'app/controllers/uploads_controller.rb'
      end

      def copy_helpers
        copy_file 'app/helpers/mercury_helper.rb'
      end

      def add_routes
        route %Q{\nmount Mercury::Engine => '/'}
        route %Q{\nresources :uploads}
        inject_into_file 'config/routes.rb', :after => "mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'\n" do
          "  match '/:name' => 'pages#showbyname', :via => :get, :as => :pagebyname"
        end
        inject_into_file 'config/routes.rb', :after =>"devise_for :users" do
          " do\n    get '/login' => 'devise/sessions#new', as: :login\n    get '/logout' => 'devise/sessions#destroy', as: :logout\n  end"
        end
        route %Q{\nroot :to => "pages#index"}
      end

      def devise_and_rails_admin_changes
        inject_into_file 'config/initializers/devise.rb', :after => "# config.authentication_keys = [ :email ]\n" do
          "  config.authentication_keys = [ :login ]\n"
        end
        gsub_file 'config/locales/devise.en.yml', 'Invalid email', 'Invalid login'
        inject_into_file 'config/initializers/rails_admin.rb', :after => "RailsAdmin.config do |config|\n" do
          "  config.authorize_with do\n    redirect_to main_app.root_path unless warden.user.admin?\n  end\n"
        end
      end

      def do_migrations
        # if options[:orm] == 'mongoid'
        # else
            migration_template 'db/migrate/mercury_create_pages.rb'
            migration_template 'db/migrate/mercury_create_regions.rb'
            migration_template 'db/migrate/mercury_create_pages_regions.rb'
            migration_template 'db/migrate/mercury_create_histories.rb'
            migration_template 'db/migrate/mercury_create_uploads.rb'
            migration_template 'db/migrate/mercury_add_changes_to_devise_users.rb'
        # end
        append_to_file 'db/seeds.rb', %Q{\nUser.create(username: 'admin', admin: 1, email: 'admin@admin.com', password: 'admin123')}
        rake "db:migrate"
        rake "db:seed"
      end

      def display_readme
        readme 'POST_INSTALL' if behavior == :invoke
      end

      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

    end
  end
end