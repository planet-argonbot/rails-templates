# Argon Template for Ruby on Rails applications

project_name = ask("What are you naming this project?")
project_name = project_name.downcase.gsub(/[^[:alnum:]]/, '')

run "rm public/index.html README"

file 'README.textile', <<-END
h2. Database Configuration

* Copy the file @config/database.yml.example@ to @config/database.yml@
* Edit @config/database.yml@-rails
* Run @rake db:create:all@
* Run @rake db:migrate@
END

["./tmp/pids", "./tmp/sessions", "./tmp/sockets", "./tmp/cache"].each do |f|
  run("rmdir ./#{f}")
end

gem 'RedCloth', :version => '3.0.3'
# commented out until Rails 2.3 fixes false libs
# gem 'rspec', :lib => false
# gem 'rspec-rails', :lib => false
gem 'rcov'

generate :rspec

run 'rm config/database.yml'

git :init

file '.gitignore', <<-END
log/\\*.log
log/\\*.pid
db/\\*.db
db/\\*.sqlite3
db/schema.rb
tmp/\\*\\*/\\*
.DS_Store
ToDo
tmp/**/*
sphinx/*.sp*
coverage

# Other useful tidbits
.DS_Store
doc/api
doc/app

# Config files
config/pa_billing.yml
config/database.yml

# database schema
db/schema.rb
END

file 'config/database.yml.example', <<-END
login: &login
  adapter: postgres
  host: localhost
  port: 5432

development:
  database: #{project_name}_development
  <<: *login

test:
  database: #{project_name}_test
  <<: *login

production:
  database: #{project_name}_production
  <<: *login
END

file 'public/stylesheets/ie.css', <<-END
/* CSS fixes for IE */
END

file 'app/helpers/application_helper.rb',
%q{module ApplicationHelper
  def set_title(str="")
    unless str.blank?
      content_for :title do
       "#{str} #{HTML_TITLE_DELIMITER} "
      end
    end
  end

  # Displays alert for links that are unimplemented
  def link_to_unimplemented( link_text, *args )
    link_to_function( link_text, 'unimplemented()', *args)
  end
end
}

run ''

file 'app/controllers/application_controller.rb',
%q{class ApplicationController < ActionController::Base
  # Makes the URL look like: page name >> PLANET ARGON"
  HTML_TITLE_DELIMITER = "&raquo;"

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  protected
    # Gracefully handle bad requests by serving a 404 page
    def render_404
      respond_to do |format|
        format.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => '404 Not Found' }
        format.xml  { render :nothing => true, :status => '404 Not Found' }
      end
      true
    end

    # Enable during staging/demoing
    # def basic_authenticate
    #   if RAILS_ENV == 'production'
    #     authenticate_or_request_with_http_basic do |username, password|
    #       username == "juan" && password == "diego"
    #     end
    #   end
    # end
end
}

file 'app/controllers/static_controller.rb',
%q{class StaticController < ApplicationController
end}

run("mkdir app/views/static")

file 'app/views/static/index.html',
%q{
<p>I am in <code>app/views/static/index.html.erb</p>
}

route "map.resource :static, :controller => 'static'"
route "map.root :controller => 'static'"

file 'app/views/layouts/application.html.erb',
%q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <title><%= (title = yield :title) ? title : "TODO: Project tag line... #{HTML_TITLE_DELIMITER} " %> TODO: Project Name</title>
  <%= stylesheet_link_tag 'master' %>
  <!--[if lte IE 6]> <link rel="stylesheet" href="/stylesheets/ie.css" type="text/css"><![endif]-->
  <%= javascript_include_tag :defaults, :cache => 'all' %>
</head>
<body>
  <!--// Flash Message Conductor //-->
  <% if flash_message_set? -%>
    <%= render_flash_messages %>
  <% end -%>

  <div id="content" class="clear">
  <%= yield %>
  </div><!-- /end content -->

  <!--// Copyright Information //-->
  <p id="copyright_info">&copy; Copyright <%= current_year_range(2009) -%></p>

<%= yield :javascript %>
</body>
</html>
}

git :add => "."

git :commit => "-m 'initial commit'"

plugin "flash-message-conductor", :git => 'git://github.com/planetargon/flash-message-conductor.git', :submodule => true
plugin "year_after_year", :git => 'git://github.com/robbyrussell/year_after_year.git', :submodule => true

git :add => '.'
git :commit => "-m 'adding flash message conductor and year after year plugins'"

puts "**********************************************"
puts "* All Done! "
puts "**********************************************"