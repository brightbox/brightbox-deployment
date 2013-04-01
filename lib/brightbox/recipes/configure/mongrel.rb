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

_cset :monit_command, "railsapp-monit"
_cset :mongrel_command, "railsapp-mongrel"
def monit_setup
  "#{fetch(:monit_command)} _#{::Version}_"
end
depend :remote, :command, fetch(:monit_command)

def mongrel_setup
  "#{fetch(:mongrel_command)} _#{::Version}_"
end
depend :remote, :command, fetch(:mongrel_command)

# Default system dependencies
depend :remote, :command, "mongrel_rails"

_cset :mongrel_pid_file, "tmp/pids/mongrel.pid"  #Stores Process ID for Mongrels
_cset :mongrel_host, :local
_cset :mongrel_port, 9200
_cset :mongrel_servers, 2
_cset(:mongrel_config_file) {File.join(deploy_to, "#{application}_mongrel_config.yml")}
case mongrel_host
when :local, :remote
  _cset :mongrel_check_url, "http://localhost"
else
  _cset :mongrel_check_url, "http://#{mongrel_host}"
end
_cset :mongrel_max_memory, 110
_cset :mongrel_max_cpu, 80


after "deploy:setup",
  "configure:monit",
  "configure:mongrel"
  "configure:apache",
  "configure:nginx"


after "deploy:cold",
  "deploy:monit:reload"

namespace :configure do

[:nginx, :apache].each do |webserver|
  desc %Q{
  [internal]Create #{webserver.to_s} config. Creates a load balancing virtual host \
  configuration based upon your specified settings

    :application      Name of the application
    :domain           Domain name which will point to the application
    :domain_aliases   Comma separated list of aliased for the main domain
    :mongrel_host     Name of application layer host (default localhost)
    :mongrel_port     Start port of the mongrel cluster (default 8000)
    :mongrel_servers  Number of servers on app host (default 2)
    :ssl_certificate  Create SSL configuration with certificate
    :ssl_key          Name of private key to use with certificate

  }
  task webserver, :roles => :web, :except => {:no_release => true} do
    run_when_generating_webserver_config_allowed do
      app_hosts = case mongrel_host
                  when :local
                    "localhost"
                  when :remote
                    roles[:app].servers.join(",")
                  else
                    mongrel_host
                  end
      sudo on_one_line( <<-END
          #{send(webserver.to_s + "_setup")}
          -n #{application}
          -d #{domain}
          #{'-a '+domain_aliases if domain_aliases}
          -w #{File.join(current_path, 'public')}
          -h #{app_hosts}
          -p #{mongrel_port}
          -s #{mongrel_servers}
          #{"-m #{max_age}" if max_age}
          #{"-c #{ssl_certificate}" if ssl_certificate}
          #{"-k #{ssl_key}" if ssl_key}
      END
          )
    end
  end
end

  desc %Q{
  [internal]Create Mongrel config. Creates a set of mongrels running \
  on the specified ports of the application server(s).

    :application      Name of the application
    :mongrel_host     Address for mongrels to listen to (default localhost)
    :mongrel_port     Start port of the mongrel cluster (default 8000)
    :mongrel_servers  Number of servers on app host (default 2)
    :mongrel_pid_file The name of the file containing the mongrel PID 

  }
  task :mongrel, :roles => :app, :except => {:no_release => true} do
    listen_address = case mongrel_host
                     when :local
                       "localhost"
                     when :remote
                       "0.0.0.0"
                     else
                       mongrel_host
                     end
    sudo on_one_line( <<-END
        #{mongrel_setup}
        -n #{application}
        -r #{current_path}
        -p #{mongrel_port}
        -s #{mongrel_servers}
        -h #{listen_address}
        -C #{mongrel_config_file}
        -P #{mongrel_pid_file}
        -e #{rails_env}
    END
        )
  end

  desc %Q{
  [internal]Create Monit config. Build a monit configuraton file \
  to look after this application

    :application      Name of the application
    :mongrel_host     Name of application layer host (default localhost)
    :mongrel_port     Start port of the mongrel cluster (default 8000)
    :mongrel_servers  Number of servers on app host (default 2)

  }
  task :monit, :roles => :app, :except => {:no_release => true} do
    listen_address = case mongrel_host
                     when :local, :remote
                       "localhost"
                     else
                       mongrel_host
                     end
    sudo on_one_line( <<-END
        #{monit_setup}
        -n #{application}
        -u #{user}
        -r #{current_path}
        -h #{listen_address}
        -p #{mongrel_port}
        -s #{mongrel_servers}
        -C #{mongrel_config_file}
        -P #{mongrel_pid_file}
        -U #{mongrel_check_url}
        -m #{mongrel_max_memory}
        -c #{mongrel_max_cpu}
    END
        )
  end
  
end
