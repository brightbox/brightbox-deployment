#    Brightbox - Easy Ruby Web Application Deployment
#    Copyright (C) 2008, David Smalley, Brightbox Systems
#
#    This file is part of the Brightbox deployment system
#
#    Brightbox gem is free software: you can redistribute it and/or modify it
#    under the terms of the GNU Affero General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General
#    Public License along with this program.  If not, see
#    <http://www.gnu.org/licenses/>.
#

namespace :configure do
  
  desc %Q{
  [internal]Create Apache config. Creates a load balancing virtual host \
  configuration based upon your specified settings

    :application      Name of the application
    :domain           Domain name which will point to the application
    :domain_aliases   Comma separated list of aliased for the main domain
    :ssl_certificate  Create SSL configuration with certificate
    :ssl_key          Name of private key to use with certificate

  }
  task :apache, :roles => :web, :except => {:no_release => true} do
    # Bail out if we don't want to generate config
    run_when_generating_webserver_config_allowed do
      # Create the configs
      sudo on_one_line( <<-END
          #{send("apache_setup")}
          -n #{application}
          -d #{domain}
          #{'-a '+domain_aliases if domain_aliases}
          -w #{File.join(current_path, 'public')}
          --passenger
          --railsenv #{rails_env}
          #{"-m #{max_age}" if max_age}
          #{"-c #{ssl_certificate}" if ssl_certificate} 
          #{"-k #{ssl_key}" if ssl_key}
          #{"-i #{ssl_intermediate}" if ssl_intermediate}
      END
          )
    end
  end
  
  task :mongrel, :roles => :app, :except => {:no_release => true} do
  end
  
  task :monit, :roles => :app, :except => {:no_release => true} do
  end
  
end