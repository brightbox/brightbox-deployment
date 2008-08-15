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
# Override standard tasks that don't do what we want

namespace :deploy do

  def mongrel_command
    "/usr/bin/mongrel_rails"
  end
  depend :remote, :command, mongrel_command

  def monit_command
    "/usr/sbin/monit"
  end
  depend :remote, :command, monit_command

  def mongrel_cluster_command(event)
    "#{mongrel_command} cluster::#{event} -C #{mongrel_config_file}" <<
    if event == "status"
      ""
    else
      " --clean"
    end
  end

  def monitor_cluster_command(event)
    case event
    when "start","restart"
      "#{monit_command} -g #{application} monitor all"
    when "stop"
      "#{monit_command} -g #{application} unmonitor all"
    else
      nil 
    end
  end

  #Override start, stop and restart so that they use mongrel to restart the
  #application servers
  %w(start stop restart status).each do |event|
    desc "Ask mongrel to #{event} your application."
    task event, :roles => :app, :except => {:no_release => true } do
      try_sudo mongrel_cluster_command(event)
      if cmd = monitor_cluster_command(event)
        sudo cmd
      end
    end
  end

  namespace :web do

    desc %Q{
      Reload the webserver
    }
    task :reload, :roles => :web, :except => {:no_release => true } do
      %w(apache nginx).each do |webserver|
        initscript = "/etc/init.d/#{webserver}"
        sudo %Q{
          sh -c '[ -f #{initscript} ] && #{initscript} reload || true'
        }
      end
    end

    desc %Q{
    [internal]reload web server if first release
    }
    task :reload_if_new, :roles => :web, :except => {:no_release => true} do
      reset! :releases
      reload if releases.length == 1
    end

  end

  namespace :monit do

    desc %Q{
      Reload monit
    }
    task :reload do
      sudo "#{monit_command} reload"
    end

  end

  desc %Q{Setup the directories and deploy the initial version of the
  application
  }
  task :initial do
    setup
    cold
  end

end
