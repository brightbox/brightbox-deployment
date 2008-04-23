#  Brightbox - Easy Ruby Web Application Deployment
#  Copyright (C) 2008, Brightbox Systems
#  Written by Neil Wilson <neil@brightbox.co.uk>
#
#  This file is part of the Brightbox deployment system
#

def rake_task(taskname)
  rake = fetch(:rake, "rake")
  rails_env = fetch(:rails_env, "production")
  rake_env = fetch(:rake_env, "")
  directory = current_release 

  run "cd #{directory}; #{rake} RAILS_ENV=#{rails_env} #{rake_env} #{taskname}"
end

namespace :database do

  desc %Q{
  [internal]Create the database if it doesn't exist
  }
  task :create, :roles => :db, :only => { :primary => true } do
    rake_task("db:create")
  end

end
