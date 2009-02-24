# Argon Template for Ruby on Rails applications

run "rm public/index.html"

run 'echo We need some documentation > README'

generate :rspec

git :init

file ".gitignore", <<-END
log/*.log
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

file "config/database.yml.example", <<-END
login: &login
  adapter: postgresql
  host: localhost
  port: 5432

development:
  database: app_name_development
  <<: *login

test:
  database: app_name_test
  <<: *login

production:
  database: app_name_production
  <<: *login
END

file 'app/helpers/application_helper.rb',
%q{module ApplicationHelper
  HTML_TITLE_DELIMITER = "&raquo;"
  
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

file 'app/controllers/application_controller.rb',
%q{class ApplicationController < ActionController::Base
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

git :add => "."

git :commit => "-m 'initial commit'"

plugin "flash-message-conductor", :git => 'git://github.com/planetargon/flash-message-conductor.git', :submodule => true
plugin "year_after_year", :git => 'git://github.com/robbyrussell/year_after_year.git', :submodule => true

git :add => '.'
git :commit => "-m 'adding flash message conductor and year after year plugins'"
