#    Brightbox - Easy Ruby Web Application Deployment
#    Copyright (C) 2008, Neil Wilson, Brightbox Systems
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

# Commands

_cset :apache_command, "railsapp-apache"
_cset :nginx_command, "railsapp-nginx"
_cset :logrotate_command, "railsapp-logrotate"
_cset :maintenance_command, "railsapp-maintenance"

def apache_setup
  "#{fetch(:apache_command)} _#{::Version}_"
end
depend :remote, :command, fetch(:apache_command)

def nginx_setup
  "#{fetch(:nginx_command)} _#{::Version}_"
end
depend :remote, :command, fetch(:nginx_command)

def logrotate_setup
  "#{fetch(:logrotate_command)} _#{::Version}_"
end
depend :remote, :command, fetch(:logrotate_command)

def maintenance_setup
  "#{fetch(:maintenance_command)} _#{::Version}_"
end
depend :remote, :command, fetch(:maintenance_command)

namespace :configure do

  desc %Q{
  [internal]Create logrotation config. Build a logrotate configuraton file \
  so that logrotate will look after the log files.

    :application      Name of the application
    :log_max_size     Rotate when log reaches this size
    :log_keep         Number of compressed logs to keep

  }
  task :logrotation, :roles => :app, :except => {:no_release => true} do
    sudo on_one_line( <<-END
        #{logrotate_setup}
        -n #{application}
        -l #{log_dir}
        -s #{log_max_size}
        -k #{log_keep}
    END
        )
  end

  desc %Q{
  [internal]Create the default maintenance website on the appropriate web servers in the shared area.
  }
  task :maintenance, :roles => :web, :except => {:no_release => true}, :on_no_matching_servers => :continue do
    run "#{maintenance_setup} #{shared_path}/system"
  end

  desc %Q{
  [internal]Run the check command if this application hasn't been
  deployed yet
  }
  task :check, :except => {:no_release => true} do
    begin
      deploy.check unless releases.length > 0
    rescue
      puts "Error detected. Have you run 'cap deploy:setup'?"
      raise
    ensure
      reset! :releases
    end
  end


end
